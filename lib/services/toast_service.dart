import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  // Instance of Toastification for displaying toasts.
  final Toastification toast = Toastification();

  // Displays a success toast with the given [message].
  void successToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  // Displays an error toast with the given [message].
  void errorToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  // Displays an info toast with the given [message].
  void infoToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  // Displays a warning toast with the given [message].
  void warningToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
