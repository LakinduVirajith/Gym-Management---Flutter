import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInput extends StatelessWidget {
  const DateInput({
    super.key,
    required this.placeholderText,
    required this.icon,
    required this.dateController,
  });

  final String placeholderText;
  final IconData icon;
  final TextEditingController dateController;

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
              controller: dateController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
