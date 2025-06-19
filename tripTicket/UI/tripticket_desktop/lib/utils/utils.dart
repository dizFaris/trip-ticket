import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';

typedef Validator = String? Function(String? value);

String? inputRequired(
  String? value, [
  String message = 'This field is required.',
]) {
  return (value == null || value.trim().isEmpty) ? message : null;
}

String? noSpecialCharacters(
  String? value, [
  String message = 'No special characters allowed.',
]) {
  if (value == null || value.isEmpty) return null;
  final regex = RegExp(r'^[a-zA-Z0-9_]+$');
  return regex.hasMatch(value) ? null : message;
}

String? onlyNumbers(String? value, [String message = 'Only numbers allowed.']) {
  if (value == null || value.isEmpty) return null;
  final regex = RegExp(r'^\d+$');
  return regex.hasMatch(value) ? null : message;
}

String? minLength(String? value, int min, [String? message]) {
  if (value == null) return null;
  return value.length >= min
      ? null
      : (message ?? 'Minimum $min characters required.');
}

String? maxLength(String? value, int max, [String? message]) {
  if (value == null) return null;
  return value.length <= max
      ? null
      : (message ?? 'Maximum $max characters allowed.');
}

String? password(String? value, [String? message]) {
  if (value == null || value.isEmpty) return null;
  final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
  return regex.hasMatch(value)
      ? null
      : (message ??
            'Password must be at least 8 characters long, contain one uppercase letter, one number, and one symbol.');
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'upcoming':
      return AppColors.statusUpcoming;
    case 'locked':
      return AppColors.statusLocked;
    case 'canceled':
      return AppColors.statusCanceled;
    case 'complete':
      return AppColors.statusComplete;
    default:
      return AppColors.statusLocked;
  }
}
