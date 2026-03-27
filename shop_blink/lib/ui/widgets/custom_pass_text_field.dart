import 'package:flutter/material.dart';
import 'package:shop_blink/constants.dart';

class CustomPassTextField extends StatefulWidget {
  const CustomPassTextField({
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
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  State<CustomPassTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomPassTextField> {
  bool _showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        onChanged: widget.onChanged,
        validator: widget.validator,
        obscureText: (_showPassword) ? false : true,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          suffixIcon: GestureDetector(
            child: Icon(
              (_showPassword)
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: kPrimaryColor,
            ),
            onTap: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          hintText: widget.hintText,
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
