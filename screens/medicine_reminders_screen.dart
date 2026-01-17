import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine_data.dart';

/// Medicine Expiry Reminders and Management Screen
class MedicineRemindersScreen extends StatelessWidget {
  const MedicineRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineProvider = Provider.of<MedicineProvider>(context);
    final medicines = medicineProvider.medicines;

    // Filter medicines with expiry dates
    final medicinesWithExpiry = medicines
        .where((m) => m.expiryDate != null)
        .toList()
      ..sort((a, b) => (a.expiryDate ?? DateTime.now())
          .compareTo(b.expiryDate ?? DateTime.now()));

    // Categorize medicines
    final expired = medicinesWithExpiry
        .where((m) => (m.expiryDate ?? DateTime.now()).isBefore(DateTime.now()))
        .toList();
    final expiringSoon = medicinesWithExpiry
        .where((m) {
          final expiry = m.expiryDate ?? DateTime.now();
          final daysUntilExpiry = expiry.difference(DateTime.now()).inDays;
          return daysUntilExpiry >= 0 && daysUntilExpiry <= 30;
        })
        .toList();
    final active = medicinesWithExpiry
        .where((m) {
          final expiry = m.expiryDate ?? DateTime.now();
          final daysUntilExpiry = expiry.difference(DateTime.now()).inDays;
          return daysUntilExpiry > 30;
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => _showNotificationSettings(context),
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: medicinesWithExpiry.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (expired.isNotEmpty) ...[
                    _buildSectionHeader('⚠️ Expired Medicines', Colors.red),
                    const SizedBox(height: 8),
                    ...expired.map((m) => _buildMedicineCard(context, m, 'expired')),
                    const SizedBox(height: 16),
                  ],
                  if (expiringSoon.isNotEmpty) ...[
                    _buildSectionHeader('⏰ Expiring Soon (≤30 days)', Colors.orange),
                    const SizedBox(height: 8),
                    ...expiringSoon.map((m) => _buildMedicineCard(context, m, 'expiring')),
                    const SizedBox(height: 16),
                  ],
                  if (active.isNotEmpty) ...[
                    _buildSectionHeader('✅ Active Medicines', Colors.green),
                    const SizedBox(height: 8),
                    ...active.map((m) => _buildMedicineCard(context, m, 'active')),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Medicines with Expiry Dates',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload medicines to track expiry dates',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color[700],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, MedicineData medicine, String status) {
    final expiry = medicine.expiryDate ?? DateTime.now();
    final daysUntilExpiry = expiry.difference(DateTime.now()).inDays;
    final isExpired = daysUntilExpiry < 0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Expired ${daysUntilExpiry.abs()} days ago';
      statusIcon = Icons.warning;
    } else if (daysUntilExpiry <= 7) {
      statusColor = Colors.red;
      statusText = 'Expires in $daysUntilExpiry days';
      statusIcon = Icons.error;
    } else if (daysUntilExpiry <= 30) {
      statusColor = Colors.orange;
      statusText = 'Expires in $daysUntilExpiry days';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.green;
      statusText = 'Expires in $daysUntilExpiry days';
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMedicineDetails(context, medicine),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medicine.disease,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Expiry: ${DateFormat('MMM dd, yyyy').format(expiry)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (medicine.batchNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Batch: ${medicine.batchNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, MedicineData medicine) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Disease', medicine.disease),
            if (medicine.batchNumber != null)
              _buildDetailRow('Batch Number', medicine.batchNumber!),
            if (medicine.expiryDate != null)
              _buildDetailRow(
                'Expiry Date',
                DateFormat('MMMM dd, yyyy').format(medicine.expiryDate!),
              ),
            _buildDetailRow('Quantity', '${medicine.purchasedQuantity} units'),
            _buildDetailRow('Status', medicine.status),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to disposal screen
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Dispose'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to donation screen
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Donate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Expiry Reminders'),
              subtitle: Text('Get notified 7 days before expiry'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Daily Health Reminders'),
              subtitle: Text('Remind to track health data'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
