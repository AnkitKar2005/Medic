# Dataset Integration Guide

## 📊 Datasets Integrated

### 1. **disease_medicine_mapping.csv**
- **Purpose**: Maps diseases to medicines with typical duration and dosage
- **Usage**: Improved medicine quantity prediction
- **Location**: `lib/ml/improved_medicine_predictor.dart`
- **Impact**: More accurate medicine quantity suggestions based on real data

### 2. **lifestyle_health_dataset.csv**
- **Purpose**: Training data for health score model
- **Usage**: Improved health score calculation with dataset-learned weights
- **Location**: `lib/ml/improved_health_score_model.dart`
- **Impact**: Better health score accuracy and personalized recommendations

### 3. **health_centers_locations.csv**
- **Purpose**: Locations of pharmacies, clinics, and NGOs
- **Usage**: Find nearby centers for medicine donation/return
- **Location**: `lib/services/location_service.dart`
- **Impact**: Location-based donation/return features

### 4. **medicine_metadata.csv**
- **Purpose**: Medicine details (category, packaging, return eligibility, toxicity)
- **Usage**: Enhanced medicine information and eco-impact calculations
- **Location**: Integrated in medicine predictor and providers
- **Impact**: Better medicine handling and eco-impact tracking

### 5. **medicine_ocr_dataset.csv**
- **Purpose**: Sample batch numbers and expiry dates for OCR training
- **Usage**: Improved OCR pattern recognition
- **Location**: `lib/services/ocr_service.dart` (can be enhanced)
- **Impact**: Better OCR accuracy for medicine images

### 6. **eco_impact_scores.csv**
- **Purpose**: Environmental impact scores for different packaging types
- **Usage**: Eco-impact calculations
- **Location**: Integrated in eco-impact dashboard
- **Impact**: Accurate environmental impact metrics

## 🚀 New Features Added

### 1. **AI Chatbot** 🤖
- **Location**: `lib/screens/chatbot_screen.dart`
- **Service**: `lib/services/chatbot_service.dart`
- **Features**:
  - Health score queries
  - Medicine-related questions
  - Disease information
  - Eco-impact guidance
  - Context-aware responses

### 2. **Improved Health Score Model**
- **Location**: `lib/ml/improved_health_score_model.dart`
- **Improvements**:
  - Dataset-trained weights
  - Better normalization functions
  - Enhanced recommendations based on dataset patterns

### 3. **Improved Medicine Predictor**
- **Location**: `lib/ml/improved_medicine_predictor.dart`
- **Improvements**:
  - Uses actual disease-medicine mapping from dataset
  - Medicine metadata integration
  - More accurate quantity predictions

### 4. **Location Service**
- **Location**: `lib/services/location_service.dart`
- **Features**:
  - Find nearby health centers
  - Filter by type (Pharmacy/Clinic/NGO)
  - Filter by donation acceptance
  - Distance calculation using Haversine formula

## 📁 File Structure

```
assets/data/
├── disease_medicine_mapping.csv
├── lifestyle_health_dataset.csv
├── health_centers_locations.csv
├── medicine_metadata.csv
├── medicine_ocr_dataset.csv
└── eco_impact_scores.csv

lib/
├── services/
│   ├── data_service.dart          # CSV loading service
│   ├── chatbot_service.dart        # AI chatbot
│   └── location_service.dart       # Health centers location
├── ml/
│   ├── improved_health_score_model.dart
│   └── improved_medicine_predictor.dart
└── screens/
    └── chatbot_screen.dart         # Chatbot UI
```

## 🔧 Setup Instructions

1. **Copy CSV files to assets**:
   ```bash
   mkdir -p assets/data
   cp "d:\Downloads\Hackathon Datasdet\*.csv" assets/data/
   ```

2. **Update pubspec.yaml** (already done):
   ```yaml
   assets:
     - assets/data/
   ```

3. **Run the app**:
   ```bash
   flutter pub get
   flutter run
   ```

## 🎯 Usage Examples

### Using Improved Health Score
```dart
final healthData = HealthData(...);
final score = await ImprovedHealthScoreModel.calculateScore(healthData);
```

### Using Improved Medicine Predictor
```dart
final prediction = await ImprovedMedicinePredictor.predictQuantity(
  disease: 'Fever',
  durationDays: 5,
  medicineName: 'Paracetamol',
);
```

### Using Location Service
```dart
final centers = await LocationService().findNearbyCenters(
  userLat: 28.6139,
  userLon: 77.2090,
  maxDistanceKm: 50.0,
  donationsOnly: true,
);
```

### Using Chatbot
```dart
final chatbot = ChatbotService();
final response = await chatbot.processMessage('How to improve health score?');
```

## 📈 Improvements Summary

1. ✅ **Health Score Accuracy**: Improved using dataset-trained weights
2. ✅ **Medicine Predictions**: More accurate using real disease-medicine mappings
3. ✅ **Location Features**: Find nearby donation centers
4. ✅ **AI Chatbot**: Interactive assistant for user queries
5. ✅ **Better Recommendations**: Dataset-based personalized suggestions
6. ✅ **Eco-Impact**: Enhanced calculations using packaging data

## 🐛 Troubleshooting

If CSV files are not loading:
1. Check file paths in `assets/data/`
2. Ensure files are included in `pubspec.yaml`
3. Run `flutter clean && flutter pub get`
4. The app will fallback to default data if files are missing

## 📝 Notes

- All dataset loading is async and cached for performance
- Fallback mechanisms ensure app works even if datasets are missing
- CSV parsing handles various data types automatically
- Location service uses Haversine formula for accurate distance calculation
