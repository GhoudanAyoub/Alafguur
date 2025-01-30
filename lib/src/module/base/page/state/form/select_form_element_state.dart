import 'package:mobx/mobx.dart';

part 'select_form_element_state.g.dart';

class SelectFormElementState = _SelectFormElementState
    with _$SelectFormElementState;

abstract class _SelectFormElementState with Store {
  @observable
  ObservableList values = ObservableList();

  @action
  void clearValues() {
    values.clear();
  }

  @action
  void setValue(dynamic value) {
    clearValues();
    if (value != null) {
      values.add(value);
    }
  }

  @action
  void addValue(dynamic value) {
    values.add(value);
  }

  @action
  void removeValue(dynamic removedValue) {
    values.removeWhere((value) => value == removedValue);
  }
}
