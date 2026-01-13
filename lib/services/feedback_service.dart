import 'package:flutter/material.dart';
import '../models/feedback_event.dart';
import '../widgets/feedback/_renderers/toast_renderer.dart';
import '../widgets/feedback/_renderers/bottom_sheet_renderer.dart';
import '../widgets/feedback/_renderers/dialog_renderer.dart';

/// Central service for showing feedback to users.
///
/// This service implements a decision model that maps [FeedbackEvent]
/// attributes to the appropriate UI pattern. Call [show] with an event
/// and the service determines the best way to display it.
///
/// ## Usage
/// ```dart
/// // Simple success toast
/// FeedbackService.show(context, FeedbackEvent.success('Copied!'));
///
/// // Warning that user should notice
/// FeedbackService.show(context, FeedbackEvent.warning('This is your ride'));
///
/// // Error that needs acknowledgment
/// FeedbackService.show(context, FeedbackEvent.error(
///   'Cannot book this ride',
///   actionLabel: 'View My Rides',
///   onAction: () => Navigator.pushNamed(context, '/my-rides'),
/// ));
///
/// // Destructive confirmation
/// FeedbackService.show(context, FeedbackEvent.destructiveConfirmation(
///   'Delete this booking?',
///   actionLabel: 'Delete',
///   onAction: () => deleteBooking(),
/// ));
/// ```
class FeedbackService {
  FeedbackService._();

  /// Show feedback to the user based on the event's attributes.
  ///
  /// The service automatically determines the appropriate UI pattern
  /// (toast, bottom sheet, dialog, etc.) based on the event's
  /// intent, scope, blocking level, and permanence.
  static void show(BuildContext context, FeedbackEvent event) {
    // Silent events produce no UI
    if (event.isSilent) return;

    final pattern = _resolvePattern(event);
    _render(context, event, pattern);
  }

  /// Resolve which UI pattern to use based on event attributes.
  ///
  /// Decision Matrix:
  /// - Hard blocking → Dialog (always)
  /// - Element scope → Inline (handled by widgets, not service)
  /// - Section scope → Banner (handled by widgets, not service)
  /// - Screen scope + soft + permanent → Bottom Sheet
  /// - Screen scope + momentary → Toast
  /// - App scope + error + hard → Dialog
  /// - App scope + persistent → App Banner
  static FeedbackPattern _resolvePattern(FeedbackEvent event) {
    // Rule 1: Hard blocking ALWAYS gets a dialog
    // User must acknowledge before continuing
    if (event.blocking == BlockingLevel.hard) {
      return FeedbackPattern.dialog;
    }

    // Rule 2: Element scope uses inline text
    // (This is typically handled by the widget itself, not the service)
    if (event.scope == FeedbackScope.element) {
      return FeedbackPattern.inlineText;
    }

    // Rule 3: Section scope uses section banner
    // (This is typically handled by the widget itself, not the service)
    if (event.scope == FeedbackScope.section) {
      return FeedbackPattern.sectionBanner;
    }

    // Rule 4: Screen scope
    if (event.scope == FeedbackScope.screen) {
      // Permanent errors that need acknowledgment → bottom sheet
      if (event.permanence == Permanence.permanent &&
          event.blocking == BlockingLevel.soft) {
        return FeedbackPattern.bottomSheet;
      }
      // Errors with actions → bottom sheet
      if (event.intent == FeedbackIntent.error && event.actionLabel != null) {
        return FeedbackPattern.bottomSheet;
      }
      // Everything else at screen scope → toast
      return FeedbackPattern.toast;
    }

    // Rule 5: App scope
    if (event.scope == FeedbackScope.app) {
      // App-wide errors → dialog
      if (event.intent == FeedbackIntent.error) {
        return FeedbackPattern.dialog;
      }
      // App-wide persistent info/warning → app banner
      if (event.permanence == Permanence.persistent) {
        return FeedbackPattern.appBanner;
      }
      // Default for app scope → dialog
      return FeedbackPattern.dialog;
    }

    // Fallback: toast
    return FeedbackPattern.toast;
  }

  /// Render the feedback using the resolved pattern.
  static void _render(
    BuildContext context,
    FeedbackEvent event,
    FeedbackPattern pattern,
  ) {
    switch (pattern) {
      case FeedbackPattern.toast:
        _showToast(context, event);
        break;

      case FeedbackPattern.bottomSheet:
        _showBottomSheet(context, event);
        break;

      case FeedbackPattern.dialog:
        _showDialog(context, event);
        break;

      case FeedbackPattern.appBanner:
        _showAppBanner(context, event);
        break;

      case FeedbackPattern.inlineText:
      case FeedbackPattern.disabledState:
      case FeedbackPattern.sectionBanner:
        // These patterns are handled by widgets directly, not the service.
        // The service should not be called for these patterns.
        // If we get here, fall back to toast.
        _showToast(context, event);
        break;

      case FeedbackPattern.silent:
        // Do nothing
        break;
    }
  }

  /// Show a toast notification at the bottom of the screen.
  static void _showToast(BuildContext context, FeedbackEvent event) {
    // Remove any existing toasts first
    _removeCurrentToast();

    final overlay = Overlay.of(context);
    _currentToastEntry = OverlayEntry(
      builder: (context) => ToastRenderer(
        event: event,
        onDismiss: () {
          _removeCurrentToast();
          event.onDismiss?.call();
        },
      ),
    );

    overlay.insert(_currentToastEntry!);

    // Auto-dismiss if momentary
    if (event.permanence == Permanence.momentary) {
      Future.delayed(event.duration, () {
        _removeCurrentToast();
      });
    }
  }

  static OverlayEntry? _currentToastEntry;

  static void _removeCurrentToast() {
    _currentToastEntry?.remove();
    _currentToastEntry = null;
  }

  /// Show a bottom sheet for errors that need more attention.
  static void _showBottomSheet(BuildContext context, FeedbackEvent event) {
    showModalBottomSheet(
      context: context,
      isDismissible: event.blocking != BlockingLevel.hard,
      enableDrag: event.blocking != BlockingLevel.hard,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetRenderer(
        event: event,
        onDismiss: () {
          Navigator.of(context).pop();
          event.onDismiss?.call();
        },
        onAction: () {
          Navigator.of(context).pop();
          event.onAction?.call();
        },
      ),
    );
  }

  /// Show a dialog for critical feedback that requires user action.
  static void _showDialog(BuildContext context, FeedbackEvent event) {
    showDialog(
      context: context,
      barrierDismissible: event.blocking != BlockingLevel.hard,
      builder: (context) => DialogRenderer(
        event: event,
        onDismiss: () {
          Navigator.of(context).pop();
          event.onDismiss?.call();
        },
        onAction: () {
          Navigator.of(context).pop();
          event.onAction?.call();
        },
      ),
    );
  }

  /// Show an app-wide banner at the top of the screen.
  /// For now, this falls back to a toast. Implement AppBannerController
  /// for true persistent banners.
  static void _showAppBanner(BuildContext context, FeedbackEvent event) {
    // TODO: Implement AppBannerController for persistent app-wide banners
    // For now, show as a toast with longer duration
    final modifiedEvent = FeedbackEvent(
      intent: event.intent,
      scope: event.scope,
      blocking: event.blocking,
      permanence: Permanence.momentary,
      message: event.message,
      title: event.title,
      actionLabel: event.actionLabel,
      onAction: event.onAction,
      customDuration: const Duration(seconds: 5),
    );
    _showToast(context, modifiedEvent);
  }
}
