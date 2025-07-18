import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripticket_desktop/app_colors.dart';

class DatePickerButton extends StatefulWidget {
  final void Function(DateTime) onDateSelected;
  final DateTime? initialDate;
  final bool enabled;

  const DatePickerButton({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.enabled = true,
  });

  @override
  DatePickerButtonState createState() => DatePickerButtonState();
}

class DatePickerButtonState extends State<DatePickerButton> {
  late DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 140,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: widget.enabled
              ? AppColors.primaryGray
              : Colors.blueGrey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: widget.enabled
            ? () async {
                final DateTime now = DateTime.now();
                final DateTime minDate = now.add(const Duration(days: 5));

                final DateTime initialPickerDate =
                    (selectedDate != null && selectedDate!.isAfter(minDate))
                    ? selectedDate!
                    : minDate;

                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialPickerDate,
                  firstDate: minDate,
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                  widget.onDateSelected(picked);
                }
              }
            : null,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : 'Select date',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
