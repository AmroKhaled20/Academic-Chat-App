import 'package:flutter/material.dart';

class CustomTextfeildWidget extends StatelessWidget {
  CustomTextfeildWidget({
    required this.hintText,
    required this.icon,
    this.obsecure,
    this.onchanged,
    this.errorText,
    this.textController,
    super.key,
  });

  final String hintText;
  final IconData icon;
  final bool? obsecure;
  final String? errorText;
  final Function(String)? onchanged;
  TextEditingController? textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onchanged,
      obscureText: obsecure ?? false,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        errorText: errorText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
