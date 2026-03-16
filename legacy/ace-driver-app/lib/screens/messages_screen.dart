

import 'package:flutter/material.dart';
import '../helpers/shared_pref_helper.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final data = await SharedPrefHelper.getRawMessages();
    setState(() => messages = data.reversed.toList());
  }

  Future<void> deleteMessage(int uiIndex) async {
    // convert UI index to storage index
    final storageIndex = messages.length - 1 - uiIndex;

    await SharedPrefHelper.deleteRawMessageAt(storageIndex);

    setState(() {
      messages.removeAt(uiIndex);
    });
  }

  Widget _buildMessageRow(String label, String value, ThemeData theme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String raw) {
    if (!raw.contains(" ")) return raw;
    final parts = raw.split(" ");
    if (parts.length < 2) return raw;
    return "${parts[0]}, ${parts[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Messages",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: messages.isEmpty
          ? Center(
              child: Text(
                "No messages available",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];

                final navId =
                    int.tryParse(msg["navid"]?.toString() ?? "0") ?? 0;

                // Theme-based colors
                final cardColor = navId == 5
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surface;

                final titleText = navId == 6 ? "Global Message" : "Message";

                final dateRaw =
                    msg['datetime']?.toString() ?? "--/--/---- --:--";
                final dateTime = formatDate(dateRaw);

                final messageContent = msg['message']?.toString() ?? "";

                final sentBy =
                    (msg['sent_by'] ??
                            msg['sentby'] ??
                            msg['sender'] ??
                            msg['sentBy'] ??
                            msg['by'] ??
                            msg['from'])
                        ?.toString() ??
                    "";

                return Dismissible(
                  key: ValueKey("$i-${msg['datetime']}"),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: theme.colorScheme.onError,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    await deleteMessage(i);
                    return false; // prevent auto-dismiss animation
                  },
                  child: Card(
                    color: cardColor,
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMessageRow("Date/Time", dateTime, theme),
                          const SizedBox(height: 6),
                          _buildMessageRow("Message", messageContent, theme),
                          const SizedBox(height: 6),
                          _buildMessageRow("Sent By", sentBy, theme),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
