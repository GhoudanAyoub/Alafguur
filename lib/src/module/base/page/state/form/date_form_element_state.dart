import 'package:mobx/mobx.dart';

part 'date_form_element_state.g.dart';

class DateFormElementState = _DateFormElementState with _$DateFormElementState;

abstract class _DateFormElementState with Store {
  @observable
  DateTime? date;
}
