// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  Key keyTextField;
  String? initialValue;
  String label;
  bool? readOnly;
  bool required;
  Function(String value)? onChanged;
  CustomTextField({
    super.key,
    this.onChanged,
    required this.required,
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
        style: TextStyle(
          color: !(readOnly ?? false) ? Colors.black : Colors.grey,
        ),
        onChanged: (value) => onChanged == null ? null : onChanged!(value),
        readOnly: readOnly ?? false,
        key: keyTextField,
        initialValue: initialValue,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          labelText: (required ? ' *' : '') + label,
          floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: !(readOnly ?? false) ? Colors.black : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: !(readOnly ?? false)
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              width: 0,
            ),
          ),
        ),
      ),
    );
  }
}
