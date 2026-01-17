# Health & Eco-Medical Assistant

An AI-powered mobile application that combines **Preventive Healthcare** with **Medical Waste Reduction**.

## 🎯 Core Features

### Part 1: Health & Wellness AI
- **Lifestyle Health Score Calculator** (0-100)
- Health Risk Classification (Good/Moderate/Poor)
- Personalized Lifestyle Recommendations
- ML-based prediction using Logistic Regression

### Part 2: Eco-Medical Solution
- **Medicine Quantity Prediction** to avoid overbuying
- **Unused Medicine Upload** with OCR for batch/expiry detection
- **Smart Return/Donation/Disposal** flow
- **Eco-Impact Dashboard** tracking waste reduction

## 🤖 AI/ML Components

1. **Lifestyle Health Score Model**: Logistic Regression-based scoring
2. **Recommendation Engine**: Rule-based + ML insights
3. **Medicine Quantity Predictor**: Disease-duration mapping
4. **OCR Model**: Google ML Kit for batch/expiry extraction
5. **Medicine Classifier**: Image labeling for category detection

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

## 📱 Platform

- **Framework**: Flutter
- **Backend**: Mocked API endpoints (ready for Node.js/Django integration)
- **ML**: On-device ML Kit + custom models
- **OCR**: Google ML Kit Text Recognition

## ⚠️ Important Notes

- This is a **decision-support system**, NOT a replacement for doctors
- AI assists in quantity optimization, NOT prescription
- All medical decisions should be verified with healthcare professionals

## 🌱 Impact

- **Health**: Preventive care awareness, lifestyle tracking
- **Environmental**: Reduced medical waste, proper disposal
- **Social**: Medicine donation to NGOs, affordable healthcare support
