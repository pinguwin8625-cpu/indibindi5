import 'package:flutter/material.dart';
import '../../models/feedback_event.dart';

/// A passive, data-driven banner that renders a [FeedbackEvent].
///
/// This widget is a pure view component. It does not make decisions about
/// what to display - it simply renders the event it's given.
///
/// For section-level feedback that should appear inline in the UI,
/// create a [FeedbackEvent] and pass it to this widget.
///
/// Example:
/// ```dart
/// FeedbackBanner(
///   event: FeedbackEvent(
///     intent: FeedbackIntent.info,
///     scope: FeedbackScope.section,
///     blocking: BlockingLevel.none,
///     permanence: Permanence.persistent,
///     message: 'This is your ride',
///   ),
/// )
/// ```
class FeedbackBanner extends StatelessWidget {
  /// The feedback event to display.
  final FeedbackEvent event;

  /// Called when the user dismisses the banner (if dismissible).
  final VoidCallback? onDismiss;

  /// Margin around the banner.
  final EdgeInsets? margin;

  /// Whether to show the intent icon.
  final bool showIcon;

  const FeedbackBanner({
    super.key,
    required this.event,
    this.onDismiss,
    this.margin,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDismissible = onDismiss != null;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: event.lightColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: event.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              event.icon,
              color: event.color,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              event.message,
              style: TextStyle(
                color: event.color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          if (isDismissible) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: event.color.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
