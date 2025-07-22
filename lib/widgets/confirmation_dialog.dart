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
      title: Text(
        confirmationMessage.topic,
        style: const TextStyle(
          fontSize: 22.0,
        ),
        textAlign: TextAlign.start,
      ),
      content: Text(
        confirmationMessage.message,
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            confirmationMessage.option1,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text(
            confirmationMessage.option2,
            style: const TextStyle(
              color: Colors.black,
            ),
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
