import '../services/data_service.dart';

/// Improved Medicine Quantity Predictor using disease_medicine_mapping.csv
/// 
/// Uses actual dataset for accurate predictions
class ImprovedMedicinePredictor {
  static final DataService _dataService = DataService.instance;

  /// Predict medicine quantity needed based on disease and duration
  static Future<MedicinePrediction> predictQuantity({
    required String disease,
    required int durationDays,
    String? medicineName,
  }) async {
    final mapping = await _dataService.getDiseaseMedicineMapping();
    final metadata = await _dataService.getMedicineMetadata();

    // Find matching disease-medicine combinations
    List<Map<String, dynamic>> matches = mapping.where((entry) {
      final entryDisease = (entry['disease'] as String?).toLowerCase();
      final entryMedicine = (entry['medicine_name'] as String?).toLowerCase();
      final diseaseLower = disease.toLowerCase();
      
      bool diseaseMatch = entryDisease.contains(diseaseLower) || 
                         diseaseLower.contains(entryDisease);
      
      if (medicineName != null) {
        final medicineLower = medicineName.toLowerCase();
        bool medicineMatch = entryMedicine.contains(medicineLower) ||
                           medicineLower.contains(entryMedicine);
        return diseaseMatch && medicineMatch;
      }
      
      return diseaseMatch;
    }).toList();

    if (matches.isEmpty) {
      // Fallback to default prediction
      return _defaultPrediction(disease, durationDays);
    }

    // Use the first match or average if multiple
    final match = matches.first;
    int typicalDuration = (match['typical_duration_days'] as num?)?.toInt() ?? durationDays;
    int quantityPerDay = (match['daily_dose_units'] as num?)?.toInt() ?? 3;
    String medicine = match['medicine_name'] as String? ?? medicineName ?? 'Medicine';

    // Use provided duration or typical duration (whichever is longer for safety)
    int effectiveDuration = durationDays > typicalDuration 
        ? durationDays 
        : typicalDuration;

    // Calculate base quantity
    int baseQuantity = effectiveDuration * quantityPerDay;
    
    // Add 10% safety buffer
    int suggestedQuantity = (baseQuantity * 1.1).ceil();

    // Get medicine metadata for additional info
    String? packagingType;
    bool? returnEligible;
    if (metadata.isNotEmpty) {
      final medMeta = metadata.firstWhere(
        (m) => (m['medicine_name'] as String?).toLowerCase() == medicine.toLowerCase(),
        orElse: () => {},
      );
      packagingType = medMeta['packaging_type'] as String?;
      returnEligible = medMeta['return_eligible'] == 1 || medMeta['return_eligible'] == '1';
    }

    String reasoning = 'Based on $disease treatment data: $quantityPerDay doses/day for $effectiveDuration days. '
        'Medicine: $medicine';
    
    if (packagingType != null) {
      reasoning += ' (Packaging: $packagingType)';
    }

    return MedicinePrediction(
      suggestedQuantity: suggestedQuantity,
      typicalDuration: typicalDuration,
      quantityPerDay: quantityPerDay,
      reasoning: reasoning,
      medicineName: medicine,
      packagingType: packagingType,
      returnEligible: returnEligible ?? true,
    );
  }

  static MedicinePrediction _defaultPrediction(String disease, int durationDays) {
    int quantityPerDay = 3; // Default
    int baseQuantity = durationDays * quantityPerDay;
    int suggestedQuantity = (baseQuantity * 1.1).ceil();

    return MedicinePrediction(
      suggestedQuantity: suggestedQuantity,
      typicalDuration: durationDays,
      quantityPerDay: quantityPerDay,
      reasoning: 'Based on general $disease treatment guidelines: $quantityPerDay doses/day for $durationDays days',
    );
  }

  /// Get all medicines for a disease
  static Future<List<String>> getMedicinesForDisease(String disease) async {
    final mapping = await _dataService.getDiseaseMedicineMapping();
    final diseaseLower = disease.toLowerCase();
    
    final medicines = mapping
        .where((entry) {
          final entryDisease = (entry['disease'] as String?).toLowerCase();
          return entryDisease.contains(diseaseLower) || 
                 diseaseLower.contains(entryDisease);
        })
        .map((entry) => entry['medicine_name'] as String)
        .where((name) => name != null)
        .toSet()
        .toList();
    
    return medicines.cast<String>();
  }
}

class MedicinePrediction {
  final int suggestedQuantity;
  final int typicalDuration;
  final int quantityPerDay;
  final String reasoning;
  final String? medicineName;
  final String? packagingType;
  final bool? returnEligible;

  MedicinePrediction({
    required this.suggestedQuantity,
    required this.typicalDuration,
    required this.quantityPerDay,
    required this.reasoning,
    this.medicineName,
    this.packagingType,
    this.returnEligible,
  });
}
