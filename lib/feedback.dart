// Centralized feedback system for user notifications.
// All feedback should go through FeedbackService.show().
// Renderers in _renderers/ are internal and should not be imported directly.

// Public API
export 'models/feedback_event.dart';
export 'services/feedback_service.dart';
export 'widgets/feedback/feedback_banner.dart';

// Note: Renderers in _renderers/ are internal and should not be imported directly.
// All feedback display should go through FeedbackService.show().
