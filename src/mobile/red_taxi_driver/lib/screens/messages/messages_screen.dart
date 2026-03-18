import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Operator messages list with read/unread status.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_Message> _messages = [
    _Message(
      id: '1',
      from: 'Operator',
      subject: 'Weekend Schedule Update',
      body: 'Please note there are additional bookings available this '
          'weekend due to the Manchester United home game. Check your '
          'schedule for updated allocations.',
      time: '14:30',
      date: '18/03/2026',
      isRead: false,
    ),
    _Message(
      id: '2',
      from: 'Operator',
      subject: 'Vehicle Inspection Reminder',
      body: 'Your vehicle inspection is due next week. Please book a slot '
          'at the depot by Friday.',
      time: '09:15',
      date: '17/03/2026',
      isRead: false,
    ),
    _Message(
      id: '3',
      from: 'System',
      subject: 'MOT Expiry Warning',
      body: 'Your MOT certificate expires on 20/04/2026. Please renew '
          'before the expiry date to avoid disruption.',
      time: '11:00',
      date: '15/03/2026',
      isRead: true,
    ),
    _Message(
      id: '4',
      from: 'Operator',
      subject: 'New Fare Structure',
      body: 'Updated fare structure effective from 01/04/2026. Please '
          'review the new pricing in your driver handbook.',
      time: '16:45',
      date: '12/03/2026',
      isRead: true,
    ),
    _Message(
      id: '5',
      from: 'System',
      subject: 'App Update Available',
      body: 'Version 2.1.0 is now available with improved GPS tracking '
          'and job offer notifications.',
      time: '08:00',
      date: '10/03/2026',
      isRead: true,
    ),
  ];

  void _toggleRead(String id) {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _messages.where((m) => !m.isRead).length;

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Messages'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: RedTaxiColors.brandRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
      body: _messages.isEmpty
          ? const Center(
              child: Text('No messages',
                  style: TextStyle(color: RedTaxiColors.textSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return _MessageTile(
                  message: msg,
                  onTap: () {
                    _toggleRead(msg.id);
                    _showDetail(context, msg);
                  },
                );
              },
            ),
    );
  }

  void _showDetail(BuildContext context, _Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RedTaxiColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RedTaxiColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                msg.subject,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('From: ${msg.from}',
                      style: const TextStyle(
                          color: RedTaxiColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  Text('${msg.date}  ${msg.time}',
                      style: const TextStyle(
                          color: RedTaxiColors.textSecondary, fontSize: 12)),
                ],
              ),
              const Divider(color: Color(0xFF2A2D3A), height: 24),
              Text(
                msg.body,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _Message {
  final String id;
  final String from;
  final String subject;
  final String body;
  final String time;
  final String date;
  final bool isRead;

  const _Message({
    required this.id,
    required this.from,
    required this.subject,
    required this.body,
    required this.time,
    required this.date,
    required this.isRead,
  });

  _Message copyWith({bool? isRead}) => _Message(
        id: id,
        from: from,
        subject: subject,
        body: body,
        time: time,
        date: date,
        isRead: isRead ?? this.isRead,
      );
}

class _MessageTile extends StatelessWidget {
  final _Message message;
  final VoidCallback? onTap;

  const _MessageTile({required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: message.isRead
              ? Colors.transparent
              : RedTaxiColors.brandRed.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: RedTaxiColors.backgroundCard,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: message.isRead
                      ? Colors.transparent
                      : RedTaxiColors.brandRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.subject,
                          style: TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 14,
                            fontWeight: message.isRead
                                ? FontWeight.w400
                                : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        message.time,
                        style: const TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.body,
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
