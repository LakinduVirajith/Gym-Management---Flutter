import 'package:flutter/material.dart';

class DropdownInput extends StatelessWidget {
  const DropdownInput({
    super.key,
    required this.hintText,
    required this.selectedItem,
    required this.onChanged,
    required this.itemOptions,
  });

  final String hintText;
  final String? selectedItem;
  final Function(String?) onChanged;
  final List<String> itemOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.black87,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedItem,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: itemOptions.map((plan) {
            return DropdownMenuItem<String>(
              value: plan,
              child: Text(
                plan,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
