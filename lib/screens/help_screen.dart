import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../widgets/scroll_indicator.dart';
import '../utils/dialog_helper.dart';
import 'chat_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openSupportChat(BuildContext context) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Show dialog to choose between suggestion or complaint
    final String? selectedType = await DialogHelper.showChoiceDialog<String>(
      context: context,
      title: 'Contact Support',
      content: 'What would you like to share with us?',
      showCancelButton: false,
      choices: [
        DialogChoice(
          label: 'Suggestion',
          value: 'Suggestion',
          color: Colors.green,
        ),
        DialogChoice(
          label: 'Complaint',
          value: 'Complaint',
          color: Colors.red,
        ),
      ],
    );
    
    if (selectedType != null) {
      _openSupportChatWithType(context, selectedType);
    }
  }

  void _openSupportChatWithType(BuildContext context, String type) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final messagingService = MessagingService();
    
    // Create NEW support conversation with unique reference number
    final supportConversation = messagingService.createSupportConversation(
      currentUser.id,
      currentUser.fullName,
      type,
    );

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: supportConversation,
          createConversationOnFirstMessage: true, // Add to inbox on first message
          initialMessagePrefix: null, // Type is already in the subject line
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.help,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent, color: Colors.white),
            onPressed: () => _openSupportChat(context),
          ),
        ],
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          children: [
          _buildHelpTile(
            icon: Icons.question_answer_outlined,
            title: l10n.faq,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.faq)),
              );
            },
          ),
          SizedBox(height: 8),
          _buildHelpTile(
            icon: Icons.support_agent,
            title: l10n.support,
            onTap: () => _openSupportChat(context),
          ),
          SizedBox(height: 8),
          _buildHelpTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.privacyPolicy)),
              );
            },
          ),
          SizedBox(height: 8),
          _buildHelpTile(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.termsOfService)),
              );
            },
          ),
          SizedBox(height: 8),
          _buildHelpTile(
            icon: Icons.download_outlined,
            title: l10n.downloadMyData,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.preparingData)),
              );
            },
          ),
          SizedBox(height: 8),
          _buildHelpTile(
            icon: Icons.info_outline,
            title: l10n.about,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.about)),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: Color(0xFFDD2C00), size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
