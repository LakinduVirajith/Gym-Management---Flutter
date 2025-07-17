import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.placeholderText,
    required this.passwordController,
  });

  final String placeholderText;
  final TextEditingController passwordController;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.black87),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: widget.passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
