import 'package:flutter/material.dart';

/// Intent describes WHAT happened
enum FeedbackIntent {
  /// Something failed or is invalid
  error,

  /// Caution, potential issue, user should be aware
  warning,

  /// Neutral information, no action needed
  info,

  /// Action completed successfully
  success,
}

/// Scope describes WHERE the feedback applies
enum FeedbackScope {
  /// Single input, button, or control (use inline text/disabled state)
  element,

  /// Group of related elements (use section banner)
  section,

  /// Current screen context (use toast or bottom sheet)
  screen,

  /// Global, cross-screen, affects entire app (use app banner or dialog)
  app,
}

/// BlockingLevel describes HOW MUCH the user is interrupted
enum BlockingLevel {
  /// User can continue freely, feedback is passive
  none,

  /// User can dismiss/ignore, but feedback demands attention
  soft,

  /// User MUST acknowledge or take action to continue
  hard,
}

/// Permanence describes HOW LONG the feedback stays
enum Permanence {
  /// Auto-dismisses after 2-4 seconds
  momentary,

  /// Stays until the condition that caused it changes
  persistent,

  /// Stays until user explicitly dismisses it
  permanent,
}

/// The resolved UI pattern to use for displaying feedback
enum FeedbackPattern {
  /// Red/orange text below a field or next to an element
  inlineText,

  /// Element is greyed out with tooltip explaining why
  disabledState,

  /// Horizontal banner within a section of the screen
  sectionBanner,

  /// Small notification that slides in from bottom, auto-dismisses
  toast,

  /// Modal sheet from bottom, can have actions
  bottomSheet,

  /// Modal dialog, blocks interaction until dismissed
  dialog,

  /// Persistent banner at top of app (e.g., offline mode)
  appBanner,

  /// No UI shown (for silent success when UI already changed)
  silent,
}

/// A feedback event that describes what happened and how to show it.
///
/// The [FeedbackService] takes this event and resolves it to a UI pattern
/// based on the combination of intent, scope, blocking, and permanence.
class FeedbackEvent {
  final FeedbackIntent intent;
  final FeedbackScope scope;
  final BlockingLevel blocking;
  final Permanence permanence;
  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final IconData? customIcon;
  final Duration? customDuration;

  const FeedbackEvent({
    required this.intent,
    required this.scope,
    required this.blocking,
    required this.permanence,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.customIcon,
    this.customDuration,
  });

  // ============================================================
  // FACTORY CONSTRUCTORS FOR COMMON PATTERNS
  // ============================================================

  /// Field validation error - shows inline red text below field.
  /// Use this for form validation errors on specific inputs.
  ///
  /// Example: "Please enter a valid email address"
  factory FeedbackEvent.fieldError(String message) => FeedbackEvent(
        intent: FeedbackIntent.error,
        scope: FeedbackScope.element,
        blocking: BlockingLevel.none,
        permanence: Permanence.persistent,
        message: message,
      );

  /// Quick success confirmation - toast that auto-dismisses.
  /// Use this when an action succeeded but UI doesn't make it obvious.
  ///
  /// Example: "Copied to clipboard"
  factory FeedbackEvent.success(String message, {Duration? duration}) =>
      FeedbackEvent(
        intent: FeedbackIntent.success,
        scope: FeedbackScope.screen,
        blocking: BlockingLevel.none,
        permanence: Permanence.momentary,
        message: message,
        customDuration: duration,
      );

  /// Silent success - no UI shown.
  /// Use when the UI change itself is confirmation enough.
  ///
  /// Example: Item added to list (list visibly updates)
  factory FeedbackEvent.silentSuccess() => FeedbackEvent(
        intent: FeedbackIntent.success,
        scope: FeedbackScope.element,
        blocking: BlockingLevel.none,
        permanence: Permanence.momentary,
        message: '',
      );

  /// Info toast - neutral information, auto-dismisses.
  /// Use for non-critical information the user should know.
  ///
  /// Example: "Refreshing data..."
  factory FeedbackEvent.info(String message) => FeedbackEvent(
        intent: FeedbackIntent.info,
        scope: FeedbackScope.screen,
        blocking: BlockingLevel.none,
        permanence: Permanence.momentary,
        message: message,
      );

  /// Warning toast - orange, auto-dismisses but more prominent.
  /// Use when user should be cautious but can continue.
  ///
  /// Example: "This is your own ride - you cannot book seats"
  factory FeedbackEvent.warning(String message) => FeedbackEvent(
        intent: FeedbackIntent.warning,
        scope: FeedbackScope.screen,
        blocking: BlockingLevel.soft,
        permanence: Permanence.momentary,
        message: message,
      );

  /// Warning that persists as a banner on the section/screen.
  /// Use when the warning applies to the entire current view.
  ///
  /// Example: "Messaging is no longer available for past rides"
  factory FeedbackEvent.persistentWarning(String message) => FeedbackEvent(
        intent: FeedbackIntent.warning,
        scope: FeedbackScope.section,
        blocking: BlockingLevel.soft,
        permanence: Permanence.persistent,
        message: message,
      );

  /// Error toast - shows red toast that auto-dismisses.
  /// Use for quick error notifications that don't need acknowledgment.
  ///
  /// Example: "You cannot book seats on your own ride"
  factory FeedbackEvent.errorToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      FeedbackEvent(
        intent: FeedbackIntent.error,
        scope: FeedbackScope.screen,
        blocking: BlockingLevel.none,
        permanence: Permanence.momentary,
        message: message,
        customDuration: duration,
      );

  /// Error that needs acknowledgment - shows bottom sheet.
  /// Use when an operation failed and user should understand why.
  ///
  /// Example: "This ride conflicts with your existing booking at 3:00 PM"
  factory FeedbackEvent.error(
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      FeedbackEvent(
        intent: FeedbackIntent.error,
        scope: FeedbackScope.screen,
        blocking: BlockingLevel.soft,
        permanence: Permanence.permanent,
        message: message,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Blocking error that MUST be acknowledged - shows dialog.
  /// Use when user cannot proceed without understanding the error.
  ///
  /// Example: "Your session has expired. Please log in again."
  factory FeedbackEvent.blockingError(
    String message, {
    String? title,
    required String actionLabel,
    required VoidCallback onAction,
  }) =>
      FeedbackEvent(
        intent: FeedbackIntent.error,
        scope: FeedbackScope.app,
        blocking: BlockingLevel.hard,
        permanence: Permanence.permanent,
        message: message,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Destructive action confirmation - shows dialog with cancel/confirm.
  /// Use before irreversible actions like delete, clear, etc.
  ///
  /// Example: "Delete this booking? This cannot be undone."
  factory FeedbackEvent.destructiveConfirmation(
    String message, {
    String? title,
    required String actionLabel,
    required VoidCallback onAction,
    VoidCallback? onDismiss,
  }) =>
      FeedbackEvent(
        intent: FeedbackIntent.warning,
        scope: FeedbackScope.app,
        blocking: BlockingLevel.hard,
        permanence: Permanence.permanent,
        message: message,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: onDismiss,
      );

  /// App-wide persistent banner - stays at top until condition changes.
  /// Use for global state like offline mode, maintenance, etc.
  ///
  /// Example: "You are offline. Some features may be unavailable."
  factory FeedbackEvent.appBanner(
    String message, {
    FeedbackIntent intent = FeedbackIntent.warning,
  }) =>
      FeedbackEvent(
        intent: intent,
        scope: FeedbackScope.app,
        blocking: BlockingLevel.none,
        permanence: Permanence.persistent,
        message: message,
      );

  // ============================================================
  // HELPER GETTERS
  // ============================================================

  Color get color => switch (intent) {
        FeedbackIntent.error => const Color(0xFFD32F2F),
        FeedbackIntent.warning => const Color(0xFFF57C00),
        FeedbackIntent.success => const Color(0xFF388E3C),
        FeedbackIntent.info => const Color(0xFF455A64),
      };

  Color get lightColor => switch (intent) {
        FeedbackIntent.error => const Color(0xFFFFEBEE),
        FeedbackIntent.warning => const Color(0xFFFFF3E0),
        FeedbackIntent.success => const Color(0xFFE8F5E9),
        FeedbackIntent.info => const Color(0xFFECEFF1),
      };

  IconData get icon => customIcon ?? switch (intent) {
        FeedbackIntent.error => Icons.error_outline,
        FeedbackIntent.warning => Icons.warning_amber_outlined,
        FeedbackIntent.success => Icons.check_circle_outline,
        FeedbackIntent.info => Icons.info_outline,
      };

  Duration get duration => customDuration ?? switch (permanence) {
        Permanence.momentary => const Duration(seconds: 3),
        Permanence.persistent => Duration.zero,
        Permanence.permanent => Duration.zero,
      };

  bool get isSilent => message.isEmpty && intent == FeedbackIntent.success;
}
