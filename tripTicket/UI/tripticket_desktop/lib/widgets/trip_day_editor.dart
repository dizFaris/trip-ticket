import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/widgets/time_picker.dart';

class TripDayEditor extends StatefulWidget {
  final List<Map<String, Object>>? initialDays;
  final void Function(List<Map<String, Object>> tripDays)? onChanged;
  final bool enabled;

  const TripDayEditor({
    super.key,
    this.initialDays,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<TripDayEditor> createState() => _TripDayEditorState();
}

class _TripDayEditorState extends State<TripDayEditor> {
  late List<Map<String, Object>> tripDays;

  @override
  void initState() {
    super.initState();
    tripDays = widget.initialDays != null
        ? List<Map<String, Object>>.from(widget.initialDays!)
        : [];
  }

  void _notifyChange() {
    widget.onChanged?.call(tripDays);
  }

  Widget dayItemsSection(int dayIndex) {
    final items = tripDays[dayIndex]['tripDayItems'] as List;

    return Column(
      children: [
        ...List.generate(
          items.length,
          (itemIndex) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: buildItemRow(dayIndex, itemIndex),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  items.add({
                    'time': '00:00',
                    'action': '',
                    'orderNumber': items.length,
                  });
                  _notifyChange();
                });
              },
              child: widget.enabled
                  ? Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 20,
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget dayRowInput(int dayIndex) {
    final day = tripDays[dayIndex];

    TextEditingController dayController = TextEditingController(
      text: day['title'] as String?,
    );
    dayController.selection = TextSelection.fromPosition(
      TextPosition(offset: dayController.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: dayIndex == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                Text(
                  'Day ${dayIndex + 1}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryYellow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: dayController,
                    enabled: widget.enabled,
                    onChanged: (value) {
                      setState(() {
                        tripDays[dayIndex]['title'] = value;
                        _notifyChange();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter text',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      filled: true,
                      fillColor: AppColors.primaryGray,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                widget.enabled
                    ? buildDayActionButton(false, dayIndex)
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: dayItemsSection(dayIndex),
          ),
        ),
      ],
    );
  }

  Widget buildDayActionButton(bool isLast, int dayIndex) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            if (isLast) {
              if ((tripDays[dayIndex]['title'] as String).trim().isNotEmpty) {
                tripDays.add({
                  'title': '',
                  'tripDayItems': [
                    {'time': '00:00', 'action': '', 'orderNumber': 0},
                  ],
                });
              }
            } else {
              tripDays.removeAt(dayIndex);
            }
            _notifyChange();
          });
        },
        child: Center(child: Icon(Icons.remove, color: Colors.black, size: 20)),
      ),
    );
  }

  Widget buildItemRow(int dayIndex, int itemIndex, {Key? key}) {
    final items = tripDays[dayIndex]['tripDayItems'] as List;
    final item = items[itemIndex];

    TextEditingController textController = TextEditingController(
      text: item['action'],
    );
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
        child: Row(
          children: [
            SimpleTimePicker(
              key: ValueKey('timepicker_${dayIndex}_${item['orderNumber']}'),
              enabled: widget.enabled,
              initialValue: item['time'],
              onChanged: (val) {
                setState(() {
                  item['time'] = val;
                  _notifyChange();
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: textController,
                enabled: widget.enabled,
                onChanged: (value) {
                  setState(() {
                    item['action'] = value;
                    _notifyChange();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter action',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  filled: true,
                  fillColor: AppColors.primaryGray,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            widget.enabled
                ? Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          final items =
                              tripDays[dayIndex]['tripDayItems'] as List;
                          items.removeAt(itemIndex);
                          _notifyChange();
                        });
                      },
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primaryGray,
        ),
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(
                        tripDays.length,
                        (index) => dayRowInput(index),
                      ),
                      widget.enabled
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(100, 36),
                                ),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text(
                                  'Add new day',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  setState(() {
                                    tripDays.add({
                                      'dayNumber': tripDays.length,
                                      'title': '',
                                      'tripDayItems': [
                                        {
                                          'time': '00:00',
                                          'action': '',
                                          'orderNumber': 0,
                                        },
                                      ],
                                    });
                                    _notifyChange();
                                  });
                                },
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
