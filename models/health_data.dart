class HealthData {
  final double sleepHours;
  final int activityLevel; // 1-5 scale
  final String dietType; // 'junk', 'balanced', 'healthy'
  final double waterIntake; // liters
  final int stressLevel; // 1-5 scale
  final double screenTime; // hours
  final bool smoking;
  final bool alcohol;
  final DateTime timestamp;

  HealthData({
    required this.sleepHours,
    required this.activityLevel,
    required this.dietType,
    required this.waterIntake,
    required this.stressLevel,
    required this.screenTime,
    required this.smoking,
    required this.alcohol,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'sleepHours': sleepHours,
        'activityLevel': activityLevel,
        'dietType': dietType,
        'waterIntake': waterIntake,
        'stressLevel': stressLevel,
        'screenTime': screenTime,
        'smoking': smoking ? 1 : 0,
        'alcohol': alcohol ? 1 : 0,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
        sleepHours: (json['sleepHours'] as num).toDouble(),
        activityLevel: json['activityLevel'] as int,
        dietType: json['dietType'] as String,
        waterIntake: (json['waterIntake'] as num).toDouble(),
        stressLevel: json['stressLevel'] as int,
        screenTime: (json['screenTime'] as num).toDouble(),
        smoking: json['smoking'] == 1,
        alcohol: json['alcohol'] == 1,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class HealthScore {
  final double score; // 0-100
  final String riskCategory; // 'Good', 'Moderate', 'Poor'
  final List<String> recommendations;

  HealthScore({
    required this.score,
    required this.riskCategory,
    required this.recommendations,
  });
}
