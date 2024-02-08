// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  Key keyTextField;
  String? initialValue;
  String label;
  bool? readOnly;
  Function(String value)? onChanged;
  CustomTextField({
    super.key,
    this.onChanged,
    required this.keyTextField,
    this.initialValue,
    this.readOnly,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: TextFormField(
        onChanged: (value) => onChanged == null ? null : onChanged!(value),
        readOnly: readOnly ?? false,
        key: keyTextField,
        initialValue: initialValue,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          floatingLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
