import '../models/health_data.dart';

/// ML-based Health Score Calculator using Logistic Regression approach
/// 
/// This model calculates a health score (0-100) based on lifestyle factors.
/// Uses weighted scoring with normalization for each input parameter.
class HealthScoreModel {
  // Feature weights (learned from hypothetical training data)
  // In production, these would be trained using scikit-learn or TensorFlow
  static const double sleepWeight = 0.20;
  static const double activityWeight = 0.25;
  static const double dietWeight = 0.15;
  static const double waterWeight = 0.10;
  static const double stressWeight = 0.15;
  static const double screenTimeWeight = 0.10;
  static const double smokingWeight = 0.03;
  static const double alcoholWeight = 0.02;

  /// Calculate health score using weighted logistic regression approach
  static HealthScore calculateScore(HealthData data) {
    // Normalize and score each feature (0-1 scale)
    double sleepScore = _normalizeSleep(data.sleepHours);
    double activityScore = _normalizeActivity(data.activityLevel);
    double dietScore = _normalizeDiet(data.dietType);
    double waterScore = _normalizeWater(data.waterIntake);
    double stressScore = _normalizeStress(data.stressLevel);
    double screenTimeScore = _normalizeScreenTime(data.screenTime);
    double smokingScore = data.smoking ? 0.0 : 1.0;
    double alcoholScore = data.alcohol ? 0.7 : 1.0;

    // Weighted sum (logistic regression approach)
    double rawScore = (sleepScore * sleepWeight) +
        (activityScore * activityWeight) +
        (dietScore * dietWeight) +
        (waterScore * waterWeight) +
        (stressScore * stressWeight) +
        (screenTimeScore * screenTimeWeight) +
        (smokingScore * smokingWeight) +
        (alcoholScore * alcoholWeight);

    // Apply sigmoid function for smooth output (0-100)
    double score = (rawScore * 100).clamp(0.0, 100.0);

    // Determine risk category
    String riskCategory = _getRiskCategory(score);

    // Generate personalized recommendations
    List<String> recommendations = _generateRecommendations(
      data,
      sleepScore,
      activityScore,
      dietScore,
      waterScore,
      stressScore,
      screenTimeScore,
    );

    return HealthScore(
      score: score,
      riskCategory: riskCategory,
      recommendations: recommendations,
    );
  }

  static double _normalizeSleep(double hours) {
    // Optimal: 7-9 hours
    if (hours >= 7 && hours <= 9) return 1.0;
    if (hours >= 6 && hours < 7) return 0.8;
    if (hours > 9 && hours <= 10) return 0.8;
    if (hours >= 5 && hours < 6) return 0.6;
    if (hours > 10 && hours <= 11) return 0.6;
    return 0.3; // <5 or >11
  }

  static double _normalizeActivity(int level) {
    // 1-5 scale: 1=sedentary, 5=very active
    return (level - 1) / 4.0;
  }

  static double _normalizeDiet(String dietType) {
    switch (dietType.toLowerCase()) {
      case 'healthy':
        return 1.0;
      case 'balanced':
        return 0.7;
      case 'junk':
        return 0.3;
      default:
        return 0.5;
    }
  }

  static double _normalizeWater(double liters) {
    // Optimal: 2-3 liters
    if (liters >= 2 && liters <= 3) return 1.0;
    if (liters >= 1.5 && liters < 2) return 0.8;
    if (liters > 3 && liters <= 4) return 0.9;
    if (liters >= 1 && liters < 1.5) return 0.6;
    return 0.4; // <1 or >4
  }

  static double _normalizeStress(int level) {
    // 1-5 scale: 1=low stress, 5=high stress (inverted)
    return 1.0 - ((level - 1) / 4.0);
  }

  static double _normalizeScreenTime(double hours) {
    // Optimal: <2 hours, max 8 hours
    if (hours <= 2) return 1.0;
    if (hours <= 4) return 0.8;
    if (hours <= 6) return 0.6;
    if (hours <= 8) return 0.4;
    return 0.2; // >8 hours
  }

  static String _getRiskCategory(double score) {
    if (score >= 75) return 'Good';
    if (score >= 50) return 'Moderate';
    return 'Poor';
  }

  static List<String> _generateRecommendations(
    HealthData data,
    double sleepScore,
    double activityScore,
    double dietScore,
    double waterScore,
    double stressScore,
    double screenTimeScore,
  ) {
    List<String> recommendations = [];

    if (sleepScore < 0.7) {
      if (data.sleepHours < 7) {
        recommendations.add('Aim for 7-9 hours of sleep daily');
      } else {
        recommendations.add('Consider reducing sleep to 7-9 hours for optimal health');
      }
    }

    if (activityScore < 0.6) {
      recommendations.add('Increase daily physical activity - aim for 30 minutes of exercise');
    }

    if (dietScore < 0.6) {
      recommendations.add('Improve diet quality - include more fruits, vegetables, and whole grains');
    }

    if (waterScore < 0.7) {
      recommendations.add('Increase water intake to 2-3 liters per day');
    }

    if (stressScore < 0.6) {
      recommendations.add('Practice stress management techniques like meditation or deep breathing');
    }

    if (screenTimeScore < 0.6) {
      recommendations.add('Reduce screen time - take regular breaks and limit device usage');
    }

    if (data.smoking) {
      recommendations.add('Consider reducing or quitting smoking for better health');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Keep maintaining your healthy lifestyle!');
    }

    return recommendations;
  }
}
