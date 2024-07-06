import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';

class ConfirmationDialog extends StatelessWidget {
  final ConfirmationMessage confirmationMessage;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.confirmationMessage,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(confirmationMessage.topic),
      content: Text(confirmationMessage.message),
      actions: <Widget>[
        TextButton(
          child: Text(
            confirmationMessage.option1,
            style: const TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            confirmationMessage.option2,
            style: const TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}
