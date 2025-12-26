import 'package:flutter/material.dart';

class DialogHelper {
  /// Shows a standardized confirmation dialog with red and green buttons
  /// [cancelText] defaults to 'Cancel' and uses GREEN color (safer option)
  /// [confirmText] defaults to 'OK' and uses GREEN color by default
  /// [isDangerous] if true, confirm button is RED (for destructive actions)
  /// [isCancelDangerous] if true, cancel button is RED (cancel is the dangerous option)
  /// Returns true if confirmed, false if cancelled
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? cancelText,
    String? confirmText,
    bool isDangerous = false, // If true, confirm button is red (for destructive actions)
    bool isCancelDangerous = false, // If true, cancel button is red (cancel is dangerous)
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: isCancelDangerous ? Colors.red : Colors.green,
              ),
              child: Text(
                cancelText ?? 'Cancel',
                style: TextStyle(
                  color: isCancelDangerous ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: isDangerous ? Colors.red : Colors.green,
              ),
              child: Text(
                confirmText ?? 'OK',
                style: TextStyle(
                  color: isDangerous ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Shows a standardized info dialog with only a green OK button
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? okText,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              child: Text(
                okText ?? 'OK',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a standardized choice dialog with multiple options
  /// Each option has a label, value, and optional color (defaults to green)
  /// Cancel button is green (safer option)
  static Future<T?> showChoiceDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    required List<DialogChoice<T>> choices,
    bool showCancelButton = true,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 0),
          actionsPadding: EdgeInsets.fromLTRB(8, 0, 8, 4),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: choices.map((choice) => InkWell(
              onTap: () => Navigator.of(dialogContext).pop(choice.value),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (choice.icon != null) ...[
                      Icon(choice.icon, size: 22, color: choice.color ?? Colors.green),
                      SizedBox(width: 8),
                    ],
                    Text(
                      choice.label,
                      style: TextStyle(
                        color: choice.color ?? Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
          actions: [
            if (showCancelButton)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Helper class for choice dialogs
class DialogChoice<T> {
  final String label;
  final T value;
  final Color? color;
  final IconData? icon;

  const DialogChoice({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });
}
