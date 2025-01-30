// Fake dart:html classes to prevent compilation errors. If possible, avoid
// creating classes like these in your modules and use this module instead.

class Element {
  String? id;

  Element append(Element e) {
    return e;
  }
}

class FormElement extends Element {
  String? action;
  String? method;

  void submit() {}
}

class InputElement extends Element {
  String? name;
  String? value;
  String? type;
}

class _FakeDocument {
  String get visibilityState => '';

  void addEventListener(String eventName, dynamic callback) {}

  Element? querySelector(String selector) {
    return Element();
  }

  Element createElement(String elementName) {
    return Element();
  }
}

class _Location {
  String? href;
}

class _Window {
  _Location location = _Location();
}

final window = _Window();
final document = _FakeDocument();
