import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/health_provider.dart';
import '../models/health_data.dart';

/// Advanced Health Analytics Screen with trends and insights
class HealthAnalyticsScreen extends StatelessWidget {
  const HealthAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final history = healthProvider.healthHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalytics(context, history),
            tooltip: 'Share Analytics',
          ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(context, history),
                  const SizedBox(height: 16),
                  _buildTrendChart(context, history),
                  const SizedBox(height: 16),
                  _buildFactorAnalysis(context, history),
                  const SizedBox(height: 16),
                  _buildRecommendationsCard(context, history),
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
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Health Data Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your lifestyle to see analytics',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<HealthData> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    final latest = history.last;
    final avgScore = history.map((h) {
      // Calculate score for each entry
      return _calculateQuickScore(h);
    }).reduce((a, b) => a + b) / history.length;

    final trend = history.length > 1
        ? _calculateQuickScore(history.last) - _calculateQuickScore(history[history.length - 2])
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.trending_up, color: trend >= 0 ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Records',
                    '${history.length}',
                    Icons.history,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Score',
                    avgScore.toStringAsFixed(0),
                    Icons.assessment,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Trend',
                    trend >= 0 ? '+${trend.toStringAsFixed(0)}' : trend.toStringAsFixed(0),
                    Icons.trending_up,
                    trend >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context, List<HealthData> history) {
    final scores = history.map((h) => _calculateQuickScore(h)).toList();
    final dates = history.map((h) => h.timestamp).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Score Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: TrendChartPainter(scores, dates),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorAnalysis(BuildContext context, List<HealthData> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    final latest = history.last;
    final factors = [
      {'name': 'Sleep', 'value': latest.sleepHours, 'optimal': 7.5, 'unit': 'hours'},
      {'name': 'Activity', 'value': latest.activityLevel.toDouble(), 'optimal': 4.0, 'unit': 'level'},
      {'name': 'Water', 'value': latest.waterIntake, 'optimal': 2.5, 'unit': 'L'},
      {'name': 'Screen Time', 'value': latest.screenTime, 'optimal': 4.0, 'unit': 'hours'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Factor Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...factors.map((factor) => _buildFactorBar(factor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorBar(Map<String, dynamic> factor) {
    final value = factor['value'] as double;
    final optimal = factor['optimal'] as double;
    final name = factor['name'] as String;
    final unit = factor['unit'] as String;
    
    final ratio = (value / optimal).clamp(0.0, 1.5);
    final color = ratio >= 0.8 && ratio <= 1.2 ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, List<HealthData> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    final latest = history.last;
    final recommendations = _generateTrendRecommendations(history);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Trend-Based Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  double _calculateQuickScore(HealthData data) {
    // Simplified score calculation
    double score = 0;
    score += (data.sleepHours / 9) * 20;
    score += (data.activityLevel / 5) * 25;
    score += data.dietType == 'healthy' ? 15 : data.dietType == 'balanced' ? 10 : 5;
    score += (data.waterIntake / 3) * 10;
    score += ((6 - data.stressLevel) / 5) * 15;
    score += ((8 - data.screenTime) / 8 * 10);
    score += data.smoking ? 0 : 3;
    score += data.alcohol ? 1 : 2;
    return score.clamp(0, 100);
  }

  List<String> _generateTrendRecommendations(List<HealthData> history) {
    if (history.length < 2) return ['Keep tracking to see trend-based recommendations'];

    final recent = history.sublist(history.length - 3);
    final scores = recent.map((h) => _calculateQuickScore(h)).toList();
    
    final isImproving = scores.last > scores.first;
    final avgSleep = recent.map((h) => h.sleepHours).reduce((a, b) => a + b) / recent.length;
    final avgActivity = recent.map((h) => h.activityLevel).reduce((a, b) => a + b) / recent.length;

    final recommendations = <String>[];

    if (isImproving) {
      recommendations.add('Great progress! Your health score is improving. Keep it up!');
    } else {
      recommendations.add('Your health score has decreased. Focus on improving lifestyle factors.');
    }

    if (avgSleep < 7) {
      recommendations.add('Your average sleep is ${avgSleep.toStringAsFixed(1)} hours. Aim for 7-9 hours.');
    }

    if (avgActivity < 3) {
      recommendations.add('Increase physical activity. Current average: ${avgActivity.toStringAsFixed(1)}/5');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Maintain your current healthy lifestyle!');
    }

    return recommendations;
  }

  void _shareAnalytics(BuildContext context, List<HealthData> history) {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics export feature coming soon!')),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  final List<double> scores;
  final List<DateTime> dates;

  TrendChartPainter(this.scores, this.dates);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final range = (maxScore - minScore).clamp(1.0, 100.0);
    final padding = 20.0;

    for (int i = 0; i < scores.length; i++) {
      final x = padding + (size.width - 2 * padding) * (i / (scores.length - 1).clamp(1, double.infinity));
      final normalizedScore = (scores[i] - minScore) / range;
      final y = size.height - padding - (size.height - 2 * padding) * normalizedScore;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final x = padding + (size.width - 2 * padding) * (i / (scores.length - 1).clamp(1, double.infinity));
      final normalizedScore = (scores[i] - minScore) / range;
      final y = size.height - padding - (size.height - 2 * padding) * normalizedScore;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
