import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CustomIntlPhoneField extends StatelessWidget {
  const CustomIntlPhoneField({
    super.key,
    required this.placeholderText,
    required this.controller,
    required this.onChanged,
    this.initialCountryCode = 'LK',
  });

  final String placeholderText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.black87,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Row(
        children: [
          Flexible(
            child: IntlPhoneField(
              controller: controller,
              initialCountryCode: initialCountryCode,
              disableLengthCheck: true,
              onChanged: (phone) => onChanged(phone.completeNumber),
              decoration: InputDecoration(
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 12.0),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14.0),
              dropdownIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
          const SizedBox(
            width: 20.0,
            height: 20.0,
            child: Icon(Icons.phone),
          )
        ],
      ),
    );
  }
}
