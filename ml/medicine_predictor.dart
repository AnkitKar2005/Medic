/// Medicine Quantity Prediction Model
/// 
/// Predicts approximate medicine quantity needed based on disease and duration.
/// Uses disease-duration mapping learned from medical guidelines.
/// 
/// IMPORTANT: This is a decision-support tool, NOT a prescription system.
class MedicineQuantityPredictor {
  // Disease to typical treatment duration mapping (days)
  // In production, this would be trained on medical prescription data
  static final Map<String, Map<String, dynamic>> diseaseMapping = {
    'fever': {
      'duration': 3,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'cold': {
      'duration': 5,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'cough': {
      'duration': 7,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'headache': {
      'duration': 2,
      'typicalDosage': '1-2 times daily',
      'quantityPerDay': 2,
    },
    'stomach pain': {
      'duration': 3,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'diarrhea': {
      'duration': 3,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'infection': {
      'duration': 7,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'allergy': {
      'duration': 5,
      'typicalDosage': '1-2 times daily',
      'quantityPerDay': 2,
    },
    'pain': {
      'duration': 3,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
    'antibiotic': {
      'duration': 7,
      'typicalDosage': '2-3 times daily',
      'quantityPerDay': 3,
    },
  };

  /// Predict medicine quantity needed
  /// 
  /// Returns suggested quantity based on disease type and duration.
  /// Includes safety buffer of 10% for completion.
  static MedicinePrediction predictQuantity({
    required String disease,
    required int durationDays,
  }) {
    String diseaseLower = disease.toLowerCase();
    
    // Find matching disease pattern
    Map<String, dynamic>? diseaseInfo;
    for (var key in diseaseMapping.keys) {
      if (diseaseLower.contains(key)) {
        diseaseInfo = diseaseMapping[key];
        break;
      }
    }

    // Default values if disease not found
    int typicalDuration = diseaseInfo?['duration'] ?? 5;
    int quantityPerDay = diseaseInfo?['typicalDosage'] ?? 3;
    
    // Use provided duration or typical duration (whichever is longer)
    int effectiveDuration = durationDays > typicalDuration 
        ? durationDays 
        : typicalDuration;

    // Calculate base quantity
    int baseQuantity = effectiveDuration * quantityPerDay;
    
    // Add 10% safety buffer
    int suggestedQuantity = (baseQuantity * 1.1).ceil();

    return MedicinePrediction(
      suggestedQuantity: suggestedQuantity,
      typicalDuration: typicalDuration,
      quantityPerDay: quantityPerDay,
      reasoning: 'Based on $disease treatment guidelines: $quantityPerDay doses/day for $effectiveDuration days',
    );
  }
}

class MedicinePrediction {
  final int suggestedQuantity;
  final int typicalDuration;
  final int quantityPerDay;
  final String reasoning;

  MedicinePrediction({
    required this.suggestedQuantity,
    required this.typicalDuration,
    required this.quantityPerDay,
    required this.reasoning,
  });
}
