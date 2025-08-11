import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';

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

String? emailFormat(String? value, [String message = 'Invalid email format.']) {
  if (value == null || value.trim().isEmpty) return null;
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
    case 'accepted':
      return AppColors.primaryBlue;
    case 'locked':
    case 'expired':
      return AppColors.primaryBlack;
    case 'canceled':
      return AppColors.primaryRed;
    case 'complete':
      return AppColors.secondaryGreen;
    default:
      return AppColors.primaryBlack;
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
