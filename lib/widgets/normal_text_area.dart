import 'package:flutter/material.dart';

class NormalTextArea extends StatelessWidget {
  const NormalTextArea({
    super.key,
    required this.placeholderText,
    required this.normalController,
  });

  final String placeholderText;
  final TextEditingController normalController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12.0, bottom: 6.0, left: 12.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: normalController,
              textAlign: TextAlign.justify,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.0,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
