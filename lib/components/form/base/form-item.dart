import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class FormItem extends ChangeNotifier {
  final TextEditingController controller;
  bool _isDirty = false;
  bool _isDisabled = false;
  String errorText;

  List<FormFieldValidator<FormItem>> _validators = [];

  String get value => this.controller?.text ?? "";

  bool get disabled => _isDisabled;
  bool get enabled => !_isDisabled;
  bool get invalid => _isDirty && this.errorText != null;
  bool get valid => !invalid;
  bool get isEmpty => this.value == "";

  FormItem({
    String text,
    List<FormFieldValidator<FormItem>> validators,
  }) : this.controller = TextEditingController(text: text) {
    this.controller.addListener(() {
      if (!isEmpty) {
        this._isDirty = true;
      }
    });
    this.controller.addListener(validateValue);
    this._validators.addAll(validators ?? []);
  }
  clear() {
    this.controller?.text = "";
    this._isDirty = false;
    this.errorText = null;
    this.notifyListeners();
  }

  void disable() {
    if (!this._isDisabled) {
      this._isDisabled = true;
      this.notifyListeners();
    }
  }

  void enable() {
    if (this._isDisabled) {
      this._isDisabled = false;
      this.notifyListeners();
    }
  }

  void setDirty() {
    this._isDirty = true;
  }

  void clearDirty() {
    this._isDirty = false;
  }

  setError(String error) {
    this._isDirty = true;
    this.errorText = error;
    this.notifyListeners();
  }

  clearError() {
    this.errorText = null;
    this.notifyListeners();
  }

  addValidator(FormFieldValidator<FormItem> validator) {
    _validators.add(validator);
  }

  addInputListener(VoidCallback listener) {
    this.controller.addListener(listener);
  }

  void validateValue() {
    if (disabled) {

    }
    if (_validators.length == 0) {
      return null;
    }
    if (!_isDirty) {
      return null;
    }
    for (var validator in _validators) {
      String errorText = validator(this);
      if (errorText != null) {
        return this.setError(errorText);
      }
    }
    this.clearError();
  }

}
