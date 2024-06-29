import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatelessWidget {
  const NumberInput({
    super.key,
    required this.placeholderText,
    required this.icon,
    required this.normalController,
  });

  final String placeholderText;
  final IconData icon;
  final TextEditingController normalController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.black87,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: normalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: Icon(icon),
          )
        ],
      ),
    );
  }
}
