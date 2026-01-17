import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

class EcoImpactScreen extends StatelessWidget {
  const EcoImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineProvider = Provider.of<MedicineProvider>(context);
    final ecoImpact = medicineProvider.ecoImpact;
    final medicines = medicineProvider.medicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Impact Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.eco, size: 64, color: Colors.green[700]),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Environmental Impact',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your contribution to reducing medical waste',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Impact Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Waste Reduced',
                    '${ecoImpact.wasteReducedKg.toStringAsFixed(1)} kg',
                    Icons.delete_outline,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'CO₂ Saved',
                    '${ecoImpact.co2SavedKg.toStringAsFixed(2)} kg',
                    Icons.air,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Medicines Returned',
                    '${ecoImpact.medicinesReturned}',
                    Icons.undo,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Medicines Donated',
                    '${ecoImpact.medicinesDonated}',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Medicines Disposed',
              '${ecoImpact.medicinesDisposed}',
              Icons.recycling,
              Colors.green,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // Impact Breakdown
            const Text(
              'Impact Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildImpactRow(
                      'Medical Waste Prevented',
                      '${ecoImpact.wasteReducedKg.toStringAsFixed(2)} kg',
                      Colors.orange,
                    ),
                    const Divider(),
                    _buildImpactRow(
                      'Carbon Footprint Reduced',
                      '${ecoImpact.co2SavedKg.toStringAsFixed(2)} kg CO₂',
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildImpactRow(
                      'Lives Potentially Helped',
                      '${ecoImpact.medicinesDonated} donations',
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Medicine History
            if (medicines.isNotEmpty) ...[
              const Text(
                'Medicine History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...medicines.map((medicine) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        _getStatusIcon(medicine.status),
                        color: _getStatusColor(medicine.status),
                      ),
                      title: Text(medicine.name),
                      subtitle: Text(
                        '${medicine.disease} • ${medicine.status}',
                      ),
                      trailing: Text(
                        '${medicine.purchasedQuantity} units',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            ],

            const SizedBox(height: 24),

            // Environmental Impact Info
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Environmental Impact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Medical waste in landfills contaminates soil and water\n'
                      '• Proper disposal prevents pharmaceutical pollution\n'
                      '• Medicine donation helps provide affordable healthcare\n'
                      '• Every returned/donated medicine reduces environmental harm',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'returned':
        return Icons.undo;
      case 'donated':
        return Icons.favorite;
      case 'disposed':
        return Icons.recycling;
      case 'unused':
        return Icons.warning;
      default:
        return Icons.medication;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'returned':
        return Colors.blue;
      case 'donated':
        return Colors.red;
      case 'disposed':
        return Colors.green;
      case 'unused':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
