import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Color backgroundColor;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: ElevatedButton(
            onPressed: (currentPage > 0 && totalPages > 0) ? onPrevious : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor: backgroundColor,
              disabledForegroundColor: Colors.grey[600],
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              shadowColor: Colors.black26,
            ),
            child: const Icon(Icons.chevron_left),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          totalPages > 0
              ? 'Page ${currentPage + 1} / $totalPages'
              : 'Page - / -',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 38,
          height: 38,
          child: ElevatedButton(
            onPressed: (currentPage < totalPages - 1 && totalPages > 0)
                ? onNext
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor: backgroundColor,
              disabledForegroundColor: Colors.grey[600],
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              shadowColor: Colors.black26,
            ),
            child: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}
