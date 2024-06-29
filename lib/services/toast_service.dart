import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  final Toastification toast = Toastification();

  void successToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void errorToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void infoToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void warningToast(String message) {
    toast.show(
      title: Text(message),
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
