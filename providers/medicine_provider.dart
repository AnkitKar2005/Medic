import 'package:flutter/foundation.dart';
import '../models/medicine_data.dart';
import '../ml/improved_medicine_predictor.dart';

class MedicineProvider extends ChangeNotifier {
  List<MedicineData> _medicines = [];
  EcoImpact _ecoImpact = EcoImpact(
    medicinesReturned: 0,
    medicinesDonated: 0,
    medicinesDisposed: 0,
    wasteReducedKg: 0.0,
    co2SavedKg: 0.0,
  );

  List<MedicineData> get medicines => _medicines;
  EcoImpact get ecoImpact => _ecoImpact;

  /// Add new medicine with AI prediction
  /// Returns the created medicine ID
  Future<String> addMedicine({
    required String name,
    required String disease,
    required int durationDays,
    required int purchasedQuantity,
  }) async {
    final prediction = await ImprovedMedicinePredictor.predictQuantity(
      disease: disease,
      durationDays: durationDays,
      medicineName: name,
    );

    final medicine = MedicineData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: prediction.medicineName ?? name,
      disease: disease,
      durationDays: durationDays,
      suggestedQuantity: prediction.suggestedQuantity,
      purchasedQuantity: purchasedQuantity,
      purchaseDate: DateTime.now(),
    );

    _medicines.add(medicine);
    notifyListeners();
    return medicine.id;
  }

  /// Add unused medicine directly (for upload flow)
  String addUnusedMedicine({
    required String name,
    required String batchNumber,
    required DateTime expiryDate,
    required int unusedQuantity,
    String? imagePath,
  }) {
    final medicine = MedicineData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      disease: 'Unknown',
      durationDays: 0,
      suggestedQuantity: unusedQuantity,
      purchasedQuantity: unusedQuantity,
      purchaseDate: DateTime.now(),
      expiryDate: expiryDate,
      batchNumber: batchNumber,
      imagePath: imagePath,
      status: 'unused',
    );

    _medicines.add(medicine);
    notifyListeners();
    return medicine.id;
  }

  /// Mark medicine as unused and ready for return/donation
  void markAsUnused(String medicineId, {
    String? batchNumber,
    DateTime? expiryDate,
    String? imagePath,
  }) {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index != -1) {
      _medicines[index] = MedicineData(
        id: _medicines[index].id,
        name: _medicines[index].name,
        disease: _medicines[index].disease,
        durationDays: _medicines[index].durationDays,
        suggestedQuantity: _medicines[index].suggestedQuantity,
        purchasedQuantity: _medicines[index].purchasedQuantity,
        purchaseDate: _medicines[index].purchaseDate,
        expiryDate: expiryDate ?? _medicines[index].expiryDate,
        batchNumber: batchNumber ?? _medicines[index].batchNumber,
        imagePath: imagePath ?? _medicines[index].imagePath,
        status: 'unused',
      );
      notifyListeners();
    }
  }

  /// Process return/donation/disposal
  void processMedicine(String medicineId, String action) {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index != -1) {
      final medicine = _medicines[index];
      _medicines[index] = MedicineData(
        id: medicine.id,
        name: medicine.name,
        disease: medicine.disease,
        durationDays: medicine.durationDays,
        suggestedQuantity: medicine.suggestedQuantity,
        purchasedQuantity: medicine.purchasedQuantity,
        purchaseDate: medicine.purchaseDate,
        expiryDate: medicine.expiryDate,
        batchNumber: medicine.batchNumber,
        imagePath: medicine.imagePath,
        status: action,
      );

      // Update eco impact
      _updateEcoImpact(action);
      notifyListeners();
    }
  }

  void _updateEcoImpact(String action) {
    switch (action) {
      case 'returned':
        _ecoImpact = EcoImpact(
          medicinesReturned: _ecoImpact.medicinesReturned + 1,
          medicinesDonated: _ecoImpact.medicinesDonated,
          medicinesDisposed: _ecoImpact.medicinesDisposed,
          wasteReducedKg: _ecoImpact.wasteReducedKg + 0.1,
          co2SavedKg: _ecoImpact.co2SavedKg + 0.05,
        );
        break;
      case 'donated':
        _ecoImpact = EcoImpact(
          medicinesReturned: _ecoImpact.medicinesReturned,
          medicinesDonated: _ecoImpact.medicinesDonated + 1,
          medicinesDisposed: _ecoImpact.medicinesDisposed,
          wasteReducedKg: _ecoImpact.wasteReducedKg + 0.15,
          co2SavedKg: _ecoImpact.co2SavedKg + 0.08,
        );
        break;
      case 'disposed':
        _ecoImpact = EcoImpact(
          medicinesReturned: _ecoImpact.medicinesReturned,
          medicinesDonated: _ecoImpact.medicinesDonated,
          medicinesDisposed: _ecoImpact.medicinesDisposed + 1,
          wasteReducedKg: _ecoImpact.wasteReducedKg + 0.05,
          co2SavedKg: _ecoImpact.co2SavedKg + 0.02,
        );
        break;
    }
  }

  List<MedicineData> getUnusedMedicines() {
    return _medicines.where((m) => m.status == 'unused').toList();
  }
}
