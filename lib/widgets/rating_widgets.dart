import 'package:flutter/material.dart';
import '../models/trip_rating.dart';
import '../models/user.dart';
import '../services/mock_users.dart';

/// Display mode for RatingCard widget.
enum RatingCardMode {
  /// Full mode with both users (from → to), avatars, timestamp
  full,
  /// Compact mode with only "from user" name, no avatars, no timestamp
  compact,
}

/// A card widget displaying a user rating with categories.
/// Used in Admin Panel ratings tab and user details.
class RatingCard extends StatelessWidget {
  final TripRating rating;
  final RatingCardMode mode;
  final void Function(User user)? onFromUserTap;
  final void Function(User user)? onToUserTap;
  final String Function(DateTime)? formatTimestamp;

  const RatingCard({
    super.key,
    required this.rating,
    this.mode = RatingCardMode.full,
    this.onFromUserTap,
    this.onToUserTap,
    this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final fromUser = MockUsers.getUserById(rating.fromUserId);
    final toUser = MockUsers.getUserById(rating.toUserId);

    return Card(
      margin: mode == RatingCardMode.full ? EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(mode == RatingCardMode.full ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with users and overall rating
            if (mode == RatingCardMode.full)
              _buildFullHeader(fromUser, toUser)
            else
              _buildCompactHeader(fromUser),

            // Category chips
            SizedBox(height: mode == RatingCardMode.full ? 12 : 8),
            Wrap(
              spacing: 8,
              runSpacing: mode == RatingCardMode.full ? 6 : 4,
              children: [
                if (rating.polite == 1) RatingCategoryChip(label: 'Polite'),
                if (rating.clean == 1) RatingCategoryChip(label: 'Clean'),
                if (rating.communicative == 1) RatingCategoryChip(label: 'Communicative'),
                if (rating.safe == 1) RatingCategoryChip(label: 'Safe'),
                if (rating.punctual == 1) RatingCategoryChip(label: 'Punctual'),
              ],
            ),

            // Timestamp (only in full mode)
            if (mode == RatingCardMode.full && formatTimestamp != null) ...[
              SizedBox(height: 8),
              Text(
                formatTimestamp!(rating.ratedAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullHeader(User? fromUser, User? toUser) {
    return Row(
      children: [
        // From user
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: fromUser != null && onFromUserTap != null
                    ? () => onFromUserTap!(fromUser)
                    : null,
                child: _buildAvatar(fromUser),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  fromUser?.fullName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Arrow
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 20, color: Colors.grey[600]),
        ),

        // To user
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: toUser != null && onToUserTap != null
                    ? () => onToUserTap!(toUser)
                    : null,
                child: _buildAvatar(toUser),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  toUser?.fullName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Overall rating badge
        SizedBox(width: 8),
        _buildRatingBadge(large: true),
      ],
    );
  }

  Widget _buildCompactHeader(User? fromUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          fromUser?.fullName ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        _buildRatingBadge(large: false),
      ],
    );
  }

  Widget _buildAvatar(User? user) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[300],
      backgroundImage: user?.profilePhotoUrl != null
          ? (user!.profilePhotoUrl!.startsWith('http')
              ? NetworkImage(user.profilePhotoUrl!) as ImageProvider
              : AssetImage(user.profilePhotoUrl!))
          : null,
      child: user?.profilePhotoUrl == null
          ? Icon(Icons.person, color: Colors.white, size: 20)
          : null,
    );
  }

  Widget _buildRatingBadge({required bool large}) {
    if (large) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber[700], size: 18),
            SizedBox(width: 4),
            Text(
              rating.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 16),
          SizedBox(width: 4),
          Text(
            rating.averageRating.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
  }
}

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
