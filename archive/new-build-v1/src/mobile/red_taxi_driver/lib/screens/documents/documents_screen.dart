import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Upload/view documents: Insurance, MOT, DBS, etc.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = [
      _Document(
        name: 'Private Hire Licence',
        icon: Icons.badge_outlined,
        status: 'Verified',
        expiry: '15/09/2026',
        isExpiringSoon: false,
      ),
      _Document(
        name: 'Vehicle Insurance',
        icon: Icons.shield_outlined,
        status: 'Verified',
        expiry: '01/06/2026',
        isExpiringSoon: false,
      ),
      _Document(
        name: 'MOT Certificate',
        icon: Icons.car_repair_outlined,
        status: 'Expiring Soon',
        expiry: '20/04/2026',
        isExpiringSoon: true,
      ),
      _Document(
        name: 'DBS Check',
        icon: Icons.verified_user_outlined,
        status: 'Verified',
        expiry: '30/11/2026',
        isExpiringSoon: false,
      ),
      _Document(
        name: 'Vehicle V5 Logbook',
        icon: Icons.description_outlined,
        status: 'Pending Review',
        expiry: 'N/A',
        isExpiringSoon: false,
        isPending: true,
      ),
      _Document(
        name: 'Driving Licence',
        icon: Icons.credit_card_outlined,
        status: 'Not Uploaded',
        expiry: null,
        isExpiringSoon: false,
        isMissing: true,
      ),
    ];

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Documents')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (_, i) {
          final doc = documents[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: doc.isMissing
                  ? Border.all(color: RedTaxiColors.error.withOpacity(0.4))
                  : doc.isExpiringSoon
                      ? Border.all(
                          color: RedTaxiColors.warning.withOpacity(0.4))
                      : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor(doc).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(doc.icon, color: _statusColor(doc), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: const TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(doc).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              doc.status,
                              style: TextStyle(
                                color: _statusColor(doc),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (doc.expiry != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Exp: ${doc.expiry}',
                              style: const TextStyle(
                                color: RedTaxiColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Upload / view button
                IconButton(
                  icon: Icon(
                    doc.isMissing ? Icons.upload_file_outlined : Icons.visibility_outlined,
                    color: doc.isMissing
                        ? RedTaxiColors.brandRed
                        : RedTaxiColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    if (doc.isMissing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upload ${doc.name}'),
                          backgroundColor: RedTaxiColors.backgroundSurface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(_Document doc) {
    if (doc.isMissing) return RedTaxiColors.error;
    if (doc.isPending) return RedTaxiColors.warning;
    if (doc.isExpiringSoon) return RedTaxiColors.warning;
    return RedTaxiColors.success;
  }
}

class _Document {
  final String name;
  final IconData icon;
  final String status;
  final String? expiry;
  final bool isExpiringSoon;
  final bool isPending;
  final bool isMissing;

  const _Document({
    required this.name,
    required this.icon,
    required this.status,
    this.expiry,
    this.isExpiringSoon = false,
    this.isPending = false,
    this.isMissing = false,
  });
}
