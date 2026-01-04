import 'package:flutter/material.dart';

/// A compact widget displaying a star icon with a rating number.
/// Used in seat labels, conversation cards, and profile displays.
class RatingDisplay extends StatelessWidget {
  final double rating;
  final double starSize;
  final double fontSize;
  final Color? starColor;
  final Color? textColor;
  final bool showNumber;
  final FontWeight fontWeight;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 12,
    this.fontSize = 11,
    this.starColor,
    this.textColor,
    this.showNumber = true,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: starSize,
          color: starColor ?? Colors.amber[700],
        ),
        if (showNumber) ...[
          SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor ?? Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// A chip widget displaying a rating category (Polite, Clean, etc.).
/// Used in admin panel ratings display.
class RatingCategoryChip extends StatelessWidget {
  final String label;
  final double iconSize;
  final double fontSize;

  const RatingCategoryChip({
    super.key,
    required this.label,
    this.iconSize = 12,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: iconSize, color: Colors.amber[700]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }
}

/// An interactive toggle for selecting rating categories in rating dialogs.
/// Used in MyBookings rating dialog.
class RatingCategoryToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RatingCategoryToggle({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.amber[700] : Colors.grey[600],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Color(0xFF2E2E2E) : Colors.grey[700],
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// Map of rating category names to their icons.
/// Used for consistent icon mapping across the app.
class RatingCategoryIcons {
  static const Map<String, IconData> icons = {
    'safe': Icons.security,
    'Safe': Icons.security,
    'punctual': Icons.schedule,
    'Punctual': Icons.schedule,
    'clean': Icons.cleaning_services,
    'Clean': Icons.cleaning_services,
    'polite': Icons.sentiment_satisfied_alt,
    'Polite': Icons.sentiment_satisfied_alt,
    'communicative': Icons.chat_bubble_outline,
    'Communicative': Icons.chat_bubble_outline,
  };

  static IconData getIcon(String category) {
    return icons[category] ?? Icons.star;
  }
}
