import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';

class SimpleTimePicker extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const SimpleTimePicker({
    super.key,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<SimpleTimePicker> createState() => _SimpleTimePickerState();
}

class _SimpleTimePickerState extends State<SimpleTimePicker> {
  int _selectedHour = 0;
  int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.contains(':')) {
      final parts = widget.initialValue!.split(':');
      _selectedHour = int.tryParse(parts[0]) ?? 0;
      _selectedMinute = int.tryParse(parts[1]) ?? 0;
    }
  }

  void _updateTime(int hour, int minute) {
    final formatted =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    widget.onChanged?.call(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedHour,
              isDense: true,
              icon: const SizedBox.shrink(),
              items: List.generate(24, (index) => index).map((hour) {
                return DropdownMenuItem(
                  value: hour,
                  child: Text(hour.toString().padLeft(2, '0')),
                );
              }).toList(),
              onChanged: widget.enabled
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _selectedHour = value;
                        });
                        _updateTime(_selectedHour, _selectedMinute);
                      }
                    }
                  : null,
            ),
          ),
        ),
        SizedBox(width: 4),
        const Text(":", style: TextStyle(fontSize: 20, color: Colors.white)),
        SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedMinute,
              isDense: true,
              icon: const SizedBox.shrink(),
              items: List.generate(60, (index) => index).map((minute) {
                return DropdownMenuItem(
                  value: minute,
                  child: Text(minute.toString().padLeft(2, '0')),
                );
              }).toList(),
              onChanged: widget.enabled
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMinute = value;
                        });
                        _updateTime(_selectedHour, _selectedMinute);
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
