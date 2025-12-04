import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/booking_storage.dart';
import '../services/messaging_service.dart';
import '../services/mock_users.dart';
import '../models/user.dart';
import '../models/booking.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    // Only allow access to admin users
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
          backgroundColor: Color(0xFFDD2C00),
        ),
        body: Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
          backgroundColor: Color(0xFFDD2C00),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.directions_car), text: 'Bookings'),
              Tab(icon: Icon(Icons.message), text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_UsersTab(), _BookingsTab(), _MessagesTab()],
        ),
      ),
    );
  }
}

// Users Management Tab
class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = MockUsers.users;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final bookingCount = BookingStorage()
            .getBookingsForUser(user.id)
            .length;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.isAdmin ? Color(0xFFDD2C00) : Colors.blue,
              child: Icon(
                user.isAdmin
                    ? Icons.admin_panel_settings
                    : (user.hasVehicle ? Icons.directions_car : Icons.person),
                color: Colors.white,
              ),
            ),
            title: Text(
              user.fullName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(user.email, style: TextStyle(fontSize: 14)),
                SizedBox(height: 2),
                Text(
                  user.isAdmin
                      ? 'Admin'
                      : (user.hasVehicle ? 'Driver' : 'Rider'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$bookingCount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'bookings',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () => _showUserDetails(context, user),
          ),
        );
      },
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    final bookings = BookingStorage().getBookingsForUser(user.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFDD2C00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      user.isAdmin
                          ? Icons.admin_panel_settings
                          : (user.hasVehicle
                                ? Icons.directions_car
                                : Icons.person),
                      color: Color(0xFFDD2C00),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                children: [
                  _buildInfoRow('ID', user.id),
                  _buildInfoRow('Phone', user.formattedPhone),
                  _buildInfoRow(
                    'Role',
                    user.isAdmin
                        ? 'Admin'
                        : (user.hasVehicle ? 'Driver' : 'Rider'),
                  ),
                  if (user.hasVehicle) ...[
                    Divider(height: 32),
                    Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow('Make', user.vehicleBrand ?? ''),
                    _buildInfoRow('Model', user.vehicleModel ?? ''),
                    _buildInfoRow('Color', user.vehicleColor ?? ''),
                    _buildInfoRow('Plate', user.licensePlate ?? ''),
                  ],
                  Divider(height: 32),
                  Text(
                    'Bookings (${bookings.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...bookings.map(
                    (booking) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          booking.route.name,
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          booking.departureTime.toString().substring(0, 16),
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          booking.isUpcoming ? 'Upcoming' : 'Past',
                          style: TextStyle(
                            fontSize: 12,
                            color: booking.isUpcoming
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// Bookings Management Tab
class _BookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: BookingStorage().bookings,
      builder: (context, bookings, _) {
        return Column(
          children: [
            // Management buttons
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: ElevatedButton.icon(
                onPressed: () => _confirmClearAll(context),
                icon: Icon(Icons.delete_sweep),
                label: Text('Clear All Bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // Bookings list
            Expanded(
              child: bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildBookingsList(context, bookings),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingsList(BuildContext context, List bookings) {
    final upcomingBookings = bookings.where((b) => b.isUpcoming).toList();
    final pastBookings = bookings.where((b) => b.isPast).toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (upcomingBookings.isNotEmpty) ...[
          Text(
            'Upcoming (${upcomingBookings.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...upcomingBookings.map(
            (booking) => _buildBookingCard(context, booking),
          ),
          SizedBox(height: 16),
        ],
        if (pastBookings.isNotEmpty) ...[
          Text(
            'Past (${pastBookings.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...pastBookings.map((booking) => _buildBookingCard(context, booking)),
        ],
      ],
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Bookings?'),
        content: Text(
          'This will permanently delete all bookings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              BookingStorage().clearAllBookings();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('All bookings cleared')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final user = MockUsers.getUserById(booking.userId);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: booking.isUpcoming ? Colors.green : Colors.grey,
          child: Icon(
            booking.userRole.toLowerCase() == 'driver'
                ? Icons.directions_car
                : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          booking.route.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              user?.fullName ?? 'Unknown User',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              booking.departureTime.toString().substring(0, 16),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${booking.selectedSeats.length}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'seats',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Messages Management Tab
class _MessagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MessagingService().conversations,
      builder: (context, conversations, _) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Show all conversations
        final allConversations = conversations.toList()
          ..sort((a, b) {
            final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
            final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
            return bLast.compareTo(aLast);
          });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: allConversations.length,
          itemBuilder: (context, index) {
            final conversation = allConversations[index];
            final messageCount = conversation.messages.length;
            final unreadCount = conversation.getUnreadCount('admin');

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: conversation.id.startsWith('support_')
                      ? Color(0xFFDD2C00)
                      : Colors.blue,
                  child: Icon(
                    conversation.id.startsWith('support_')
                        ? Icons.support_agent
                        : Icons.message,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  conversation.routeName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      '${conversation.driverName} ↔ ${conversation.riderName}',
                      style: TextStyle(fontSize: 14),
                    ),
                    if (conversation.lastMessage != null)
                      Text(
                        conversation.lastMessage!.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$messageCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'messages',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    if (unreadCount > 0)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFDD2C00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
