import 'package:flutter/material.dart';
import '../../../models/feedback_event.dart';

/// INTERNAL: Do not use directly. Use [FeedbackService.show] instead.
///
/// Bottom sheet renderer for errors that need more attention.
/// This widget is instantiated only by FeedbackService.
class BottomSheetRenderer extends StatelessWidget {
  final FeedbackEvent event;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const BottomSheetRenderer({
    super.key,
    required this.event,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: event.lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.icon,
                size: 32,
                color: event.color,
              ),
            ),
            const SizedBox(height: 20),

            // Title (if provided)
            if (event.title != null) ...[
              Text(
                event.title!,
                style: const TextStyle(
                  fontSize: 20,
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
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Action button (if provided)
            if (event.actionLabel != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    event.actionLabel!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Dismiss button (if not hard blocking)
            if (event.blocking != BlockingLevel.hard) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
