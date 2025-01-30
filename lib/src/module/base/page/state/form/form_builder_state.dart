import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../service/form_validation_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../widget/form/form_builder_widget.dart';
import '../root_state.dart';

part 'form_builder_state.g.dart';

class FormBuilderState = _FormBuilderState with _$FormBuilderState;

abstract class _FormBuilderState with Store {
  final FormValidationService formValidationService;
  final RootState rootState;

  FormRendererCallback? formRendererCallback;
  OnChangedValueCallback? formOnChangedCallback;
  OnFocusedCallback? formOnFocusedCallback;

  FormTheme? formTheme;

  @observable
  ObservableMap<String, FormElementModel> elementsMap = ObservableMap();

  // keeps the validation timer handlers
  // (we need it to have a possibility to stop any validation timer when a value is changed)
  Map<String, Timer> _validationTimerHandlers = {};

  _FormBuilderState({
    required this.formValidationService,
    required this.rootState,
  }) {
    formValidationService.setEmailRegexp(
      rootState.getSiteSetting('emailRegexp', ''),
    );
  }

  @action
  void updateElementValue(String key, dynamic value) {
    // make sure we have a registered element
    if (elementsMap.containsKey(key)) {
      // if we don't have any kind of validators
      // we just mark it as valid and update its value
      if (_isValidatorListEmpty(key)) {
        updateElement(
          key: key,
          value: value,
          isValid: true,
          errorMessage: null,
        );

        return;
      }

      // stop all possible pending async validation sessions
      if (_validationTimerHandlers.containsKey(key)) {
        _validationTimerHandlers[key]!.cancel();
      }

      // update a value and mark the element as not valid until it's not validated
      updateElement(
        key: key,
        value: value,
        isValid: false,
        errorMessage: null,
        isValidationStarted: false,
      );

      // validate element
      final isValid = elementsMap[key]?.validators != null
          ? syncValidateElementValue(key, value)
          : true;

      final asyncValidators = elementsMap[key]?.asyncValidators ?? [];

      // asynchronous validation
      if (isValid && asyncValidators.length != 0) {
        // mark as not valid despite it was marked as valid previously by sync validators
        updateElement(
          key: key,
          value: value,
          isValid: false,
          errorMessage: null,
        );

        // to prevent validation flooding we use a small delay between async validations
        _validationTimerHandlers[key] = Timer(
          Duration(milliseconds: VALIDATION_INTERVAL_MILL_SEC),
          () {
            asyncValidateElementValue(key, value);
          },
        );
      }
    }
  }

  @action
  bool syncValidateElementValue(
    String key,
    dynamic value,
  ) {
    // by default it's always valid
    bool isElementValid = true;
    String? errorMessage;

    // call sync validators
    for (var validator in elementsMap[key]!.validators!) {
      errorMessage = formValidationService.callSyncValidator(
        validator.name,
        value,
        elementsMap,
        validator.message,
        (validator.params != null ? validator.params : {}),
      );

      if (errorMessage != null) {
        isElementValid = false;
        break;
      }
    }

    // update a value and update the validated status
    updateElement(
      value: value,
      key: key,
      isValid: isElementValid,
      errorMessage: errorMessage,
    );

    return isElementValid;
  }

  @action
  Future<bool> asyncValidateElementValue(
    String key,
    dynamic value,
  ) async {
    // by default it's always valid
    bool isElementValid = true;
    String? errorMessage;

    // mark the element as in validation
    updateElementValidationFlag(
      key: key,
      isValidationStarted: true,
    );

    // call the list of async validators
    for (var validator in elementsMap[key]!.asyncValidators!) {
      errorMessage = await formValidationService.callAsyncValidator(
        validator.name,
        value,
        elementsMap,
        validator.message,
        (validator.params != null ? validator.params : {}),
      );

      if (errorMessage != null) {
        isElementValid = false;
        break;
      }
    }

    // make sure that the value is the same as it was before starting validation
    if (value == elementsMap[key]!.value) {
      updateElement(
        value: value,
        key: key,
        isValid: isElementValid,
        errorMessage: errorMessage,
        isValidationStarted: false,
      );

      return isElementValid;
    }

    // it seems the validation result already irrelevant (due to a changed initial value)
    // and should be skipped
    return false;
  }

  @action
  void updateElementValidationFlag({
    required String key,
    required bool isValidationStarted,
  }) {
    final clonedElement = cloneElement(elementsMap[key]!);
    clonedElement.isValidationStarted = isValidationStarted;

    // replace the old element with the newest one
    elementsMap[key] = clonedElement;
  }

  @action
  void updateElement({
    required String key,
    dynamic value,
    bool? isValid,
    String? errorMessage,
    bool? isValidationStarted,
  }) {
    // PS: we must not mutate properties directly, instead
    // we use replacing of the whole element with an updated one
    final clonedElement = cloneElement(elementsMap[key]!);

    clonedElement.value = value;
    clonedElement.isValid = isValid;
    clonedElement.errorMessage = errorMessage;

    if (isValidationStarted != null) {
      clonedElement.isValidationStarted = isValidationStarted;
    }

    // replace the old element with the newest one
    elementsMap[key] = clonedElement;
  }

  /// reset form values
  @action
  void reset() {
    elementsMap.forEach((key, _) {
      updateElementValue(key, null);
    });
  }

  /// check if the form valid or not
  Future<bool> isFormValid() async {
    bool isFormValid = true;
    List<String> notValidatedElementsKeys = [];

    // check every form element
    elementsMap.forEach((key, formElementModel) {
      // we've found at least a one not valid element
      if (formElementModel.isValid == false) {
        isFormValid = false;
      }

      // the element is not yet validated
      if (formElementModel.isValid == null) {
        notValidatedElementsKeys.add(key);
      }
    });

    // validate the rest of not validated elements
    if (notValidatedElementsKeys.isNotEmpty) {
      bool isRestElementsValid = true;
      final List<Future<bool>> notValidatedAsyncElements = [];

      notValidatedElementsKeys.forEach((key) {
        if (!_isValidatorListEmpty(key)) {
          // update a value and mark as not valid
          updateElement(
            key: key,
            value: elementsMap[key]!.value,
            isValid: false,
            errorMessage: null,
            isValidationStarted: false,
          );

          // validate element
          final isElementValid = elementsMap[key]!.validators != null
              ? syncValidateElementValue(key, elementsMap[key]!.value)
              : true;

          // asynchronous validation
          if (isElementValid && elementsMap[key]!.asyncValidators != null) {
            // mark as not valid despite it was marked as valid previously
            updateElement(
              key: key,
              value: elementsMap[key]!.value,
              isValid: false,
              errorMessage: null,
            );

            notValidatedAsyncElements
                .add(asyncValidateElementValue(key, elementsMap[key]!.value));
          }

          if (isElementValid == false) {
            isRestElementsValid = false;
          }
        }
      });

      // some of the rest elements are not valid
      // so the form is also not valid
      if (isRestElementsValid == false) {
        isFormValid = false;
      }

      // async validation of the rest of elements
      if (isFormValid == true && notValidatedAsyncElements.isNotEmpty) {
        final List<bool> asyncResult =
            await Future.wait(notValidatedAsyncElements);

        // check the other elements
        asyncResult.forEach((isElementValidated) {
          if (!isElementValidated) {
            isFormValid = false;
          }
        });
      }
    }

    return isFormValid;
  }

  /// create a cloned form element
  FormElementModel cloneElement(FormElementModel element) {
    return FormElementModel.fromJson(element.toJson());
  }

  bool _isValidatorListEmpty(String key) {
    if (elementsMap[key]!.validators == null &&
        elementsMap[key]!.asyncValidators == null) {
      return true;
    }

    return false;
  }
}
