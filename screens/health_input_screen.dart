import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../models/health_data.dart';
import 'health_results_screen.dart';

class HealthInputScreen extends StatefulWidget {
  const HealthInputScreen({super.key});

  @override
  State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  double _sleepHours = 7.0;
  int _activityLevel = 3;
  String _dietType = 'balanced';
  double _waterIntake = 2.0;
  int _stressLevel = 3;
  double _screenTime = 4.0;
  bool _smoking = false;
  bool _alcohol = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifestyle Health Assessment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Track your daily lifestyle habits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI will analyze your inputs and provide personalized health insights',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sleep Hours
              _buildSectionTitle('Sleep Hours'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_sleepHours.toStringAsFixed(1)} hours',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _sleepHours,
                        min: 4,
                        max: 12,
                        divisions: 16,
                        label: '${_sleepHours.toStringAsFixed(1)} hours',
                        onChanged: (value) {
                          setState(() => _sleepHours = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Activity Level
              _buildSectionTitle('Physical Activity Level'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _getActivityLabel(_activityLevel),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _activityLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _getActivityLabel(_activityLevel),
                        onChanged: (value) {
                          setState(() => _activityLevel = value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Diet Type
              _buildSectionTitle('Diet Type'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'junk', label: Text('Junk')),
                      ButtonSegment(value: 'balanced', label: Text('Balanced')),
                      ButtonSegment(value: 'healthy', label: Text('Healthy')),
                    ],
                    selected: {_dietType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _dietType = newSelection.first);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Water Intake
              _buildSectionTitle('Water Intake (Liters)'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_waterIntake.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _waterIntake,
                        min: 0.5,
                        max: 5.0,
                        divisions: 9,
                        label: '${_waterIntake.toStringAsFixed(1)} L',
                        onChanged: (value) {
                          setState(() => _waterIntake = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stress Level
              _buildSectionTitle('Stress Level'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _getStressLabel(_stressLevel),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _stressLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _getStressLabel(_stressLevel),
                        onChanged: (value) {
                          setState(() => _stressLevel = value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Screen Time
              _buildSectionTitle('Screen Time (Hours)'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_screenTime.toStringAsFixed(1)} hours',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _screenTime,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        label: '${_screenTime.toStringAsFixed(1)} hours',
                        onChanged: (value) {
                          setState(() => _screenTime = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Smoking & Alcohol
              _buildSectionTitle('Lifestyle Habits'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Smoking'),
                        value: _smoking,
                        onChanged: (value) {
                          setState(() => _smoking = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Alcohol Consumption'),
                        value: _alcohol,
                        onChanged: (value) {
                          setState(() => _alcohol = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateHealthScore,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calculate Health Score',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getActivityLabel(int level) {
    switch (level) {
      case 1:
        return 'Sedentary';
      case 2:
        return 'Light Activity';
      case 3:
        return 'Moderate Activity';
      case 4:
        return 'Active';
      case 5:
        return 'Very Active';
      default:
        return 'Moderate';
    }
  }

  String _getStressLabel(int level) {
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Moderate';
    }
  }

  void _calculateHealthScore() {
    if (_formKey.currentState!.validate()) {
      final healthData = HealthData(
        sleepHours: _sleepHours,
        activityLevel: _activityLevel,
        dietType: _dietType,
        waterIntake: _waterIntake,
        stressLevel: _stressLevel,
        screenTime: _screenTime,
        smoking: _smoking,
        alcohol: _alcohol,
      );

      await Provider.of<HealthProvider>(context, listen: false)
          .updateHealthData(healthData);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthResultsScreen(),
          ),
        );
      }
    }
  }
}
