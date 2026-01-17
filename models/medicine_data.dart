class MedicineData {
  final String id;
  final String name;
  final String disease;
  final int durationDays;
  final int suggestedQuantity;
  final int purchasedQuantity;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? imagePath;
  final String status; // 'active', 'unused', 'returned', 'donated', 'disposed'

  MedicineData({
    required this.id,
    required this.name,
    required this.disease,
    required this.durationDays,
    required this.suggestedQuantity,
    required this.purchasedQuantity,
    required this.purchaseDate,
    this.expiryDate,
    this.batchNumber,
    this.imagePath,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'disease': disease,
        'durationDays': durationDays,
        'suggestedQuantity': suggestedQuantity,
        'purchasedQuantity': purchasedQuantity,
        'purchaseDate': purchaseDate.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'batchNumber': batchNumber,
        'imagePath': imagePath,
        'status': status,
      };

  factory MedicineData.fromJson(Map<String, dynamic> json) => MedicineData(
        id: json['id'] as String,
        name: json['name'] as String,
        disease: json['disease'] as String,
        durationDays: json['durationDays'] as int,
        suggestedQuantity: json['suggestedQuantity'] as int,
        purchasedQuantity: json['purchasedQuantity'] as int,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        batchNumber: json['batchNumber'] as String?,
        imagePath: json['imagePath'] as String?,
        status: json['status'] as String,
      );
}

class EcoImpact {
  final int medicinesReturned;
  final int medicinesDonated;
  final int medicinesDisposed;
  final double wasteReducedKg;
  final double co2SavedKg;

  EcoImpact({
    required this.medicinesReturned,
    required this.medicinesDonated,
    required this.medicinesDisposed,
    required this.wasteReducedKg,
    required this.co2SavedKg,
  });
}
