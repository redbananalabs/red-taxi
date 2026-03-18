import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Send direct or global message to drivers.
class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _messageCtrl = TextEditingController();
  String _recipient = 'all';
  String? _selectedDriver;
  bool _isSending = false;

  final _drivers = [
    'Sean Byrne',
    'Liam Doyle',
    'Declan Ryan',
    'Michael Nolan',
    'Brian Kavanagh',
    'Paul Fitzgerald',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: RedTaxiColors.error,
        ),
      );
      return;
    }

    if (_recipient == 'driver' && _selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a driver'),
          backgroundColor: RedTaxiColors.error,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    // TODO: call API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_recipient == 'all'
              ? 'Message sent to all drivers'
              : 'Message sent to $_selectedDriver'),
          backgroundColor: RedTaxiColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Send Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient type
            const Text(
              'Send to',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _RecipientOption(
                    icon: Icons.campaign_outlined,
                    label: 'All Drivers',
                    isSelected: _recipient == 'all',
                    onTap: () => setState(() {
                      _recipient = 'all';
                      _selectedDriver = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RecipientOption(
                    icon: Icons.person_outline,
                    label: 'One Driver',
                    isSelected: _recipient == 'driver',
                    onTap: () => setState(() => _recipient = 'driver'),
                  ),
                ),
              ],
            ),

            // Driver dropdown
            if (_recipient == 'driver') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDriver,
                hint: const Text(
                  'Select driver',
                  style: TextStyle(color: RedTaxiColors.textSecondary),
                ),
                dropdownColor: RedTaxiColors.backgroundCard,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_search,
                      color: RedTaxiColors.textSecondary, size: 20),
                ),
                items: _drivers
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDriver = v),
              ),
            ],
            const SizedBox(height: 24),

            // Message field
            const Text(
              'Message',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                    color: RedTaxiColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: RedTaxiColors.brandRed),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick templates
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickTemplate(
                    label: 'High demand area',
                    onTap: () => _messageCtrl.text =
                        'High demand in city centre. Please head there if available.',
                  ),
                  _QuickTemplate(
                    label: 'Shift reminder',
                    onTap: () => _messageCtrl.text =
                        'Reminder: Your shift starts in 30 minutes.',
                  ),
                  _QuickTemplate(
                    label: 'Weather alert',
                    onTap: () => _messageCtrl.text =
                        'Heavy rain expected. Drive carefully and expect delays.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Send button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: RedTaxiColors.textPrimary,
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(
                  _isSending ? 'Sending...' : 'Send Message',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RecipientOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecipientOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? RedTaxiColors.brandRed.withOpacity(0.15)
              : RedTaxiColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RedTaxiColors.brandRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.textSecondary,
                size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTemplate extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTemplate({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: RedTaxiColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2A2D3A),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
