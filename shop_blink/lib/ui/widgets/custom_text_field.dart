import 'package:flutter/material.dart';
import 'package:shop_blink/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.hintText,
    this.prefixIcon,
    this.sufixIcon,
    required this.onChanged,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);
  final String hintText;
  final Widget? prefixIcon;
  final Widget? sufixIcon;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(color: kPrimaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1),
          ),
        ),
      ),
    );
  }
}
