import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  // INSTANCE OF TOASTIFICATION FOR DISPLAYING TOASTS.
  final Toastification toast = Toastification();

  // DISPLAYS A SUCCESS TOAST WITH THE GIVEN [MESSAGE].
  void successToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(milliseconds: 3000),
    );
  }

  // DISPLAYS AN ERROR TOAST WITH THE GIVEN [MESSAGE].
  void errorToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(milliseconds: 3000),
    );
  }

  // DISPLAYS AN INFO TOAST WITH THE GIVEN [MESSAGE].
  void infoToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(milliseconds: 3000),
    );
  }

  // DISPLAYS A WARNING TOAST WITH THE GIVEN [MESSAGE].
  void warningToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(milliseconds: 3000),
    );
  }
}
