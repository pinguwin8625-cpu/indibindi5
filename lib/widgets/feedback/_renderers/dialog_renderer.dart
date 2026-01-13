import 'package:flutter/material.dart';
import '../../../models/feedback_event.dart';

/// INTERNAL: Do not use directly. Use [FeedbackService.show] instead.
///
/// Dialog renderer for critical feedback requiring user action.
/// This widget is instantiated only by FeedbackService.
class DialogRenderer extends StatelessWidget {
  final FeedbackEvent event;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const DialogRenderer({
    super.key,
    required this.event,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDestructive = event.intent == FeedbackIntent.warning &&
        event.blocking == BlockingLevel.hard;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: event.lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              event.icon,
              size: 28,
              color: event.color,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          if (event.title != null) ...[
            Text(
              event.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Message
          Text(
            event.message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        // Cancel/Dismiss button (if not hard blocking without alternative)
        if (event.blocking != BlockingLevel.hard ||
            event.intent == FeedbackIntent.warning)
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: Text(
              isDestructive ? 'Cancel' : 'Dismiss',
              style: const TextStyle(fontSize: 15),
            ),
          ),

        // Action button
        if (event.actionLabel != null)
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? const Color(0xFFD32F2F)
                  : event.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              event.actionLabel!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
