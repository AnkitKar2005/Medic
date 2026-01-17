import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../ml/improved_medicine_predictor.dart';

class MedicinePredictionScreen extends StatefulWidget {
  const MedicinePredictionScreen({super.key});

  @override
  State<MedicinePredictionScreen> createState() =>
      _MedicinePredictionScreenState();
}

class _MedicinePredictionScreenState extends State<MedicinePredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _purchasedQuantityController = TextEditingController();

  MedicinePrediction? _prediction;
  String _disease = '';
  bool _isLoading = false;

  final List<String> _commonDiseases = [
    'Fever',
    'Cold',
    'Cough',
    'Headache',
    'Stomach Pain',
    'Diarrhea',
    'Infection',
    'Allergy',
    'Pain',
    'Antibiotic',
  ];

  @override
  void dispose() {
    _medicineNameController.dispose();
    _durationController.dispose();
    _purchasedQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Quantity Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                        'AI-Powered Medicine Optimization',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get AI suggestions for medicine quantity to avoid overbuying and reduce waste',
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

              // Medicine Name
              TextFormField(
                controller: _medicineNameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Disease
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _commonDiseases;
                  }
                  return _commonDiseases.where((disease) => disease
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String value) {
                  setState(() {
                    _disease = value;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode) {
                  // Update disease state when text changes
                  controller.addListener(() {
                    if (_disease != controller.text) {
                      setState(() {
                        _disease = controller.text;
                      });
                    }
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Disease / Condition',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter disease name';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (Days)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Predict Button
              ElevatedButton(
                onPressed: _isLoading ? null : _predictQuantity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get AI Prediction',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Loading Indicator
              if (_isLoading)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // Prediction Result
              if (_prediction != null && !_isLoading) ...[
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'AI Suggested Quantity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_prediction!.suggestedQuantity} units',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _prediction!.reasoning,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Purchased Quantity Input
                TextFormField(
                  controller: _purchasedQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity Purchased',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_cart),
                    helperText: 'Enter the actual quantity you purchased',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter purchased quantity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Save Medicine Button
                ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Medicine',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Disclaimer
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is a decision-support tool. AI does NOT prescribe medicines. Always follow doctor\'s advice and prescription.',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _predictQuantity() async {
    if (_formKey.currentState!.validate()) {
      final duration = int.parse(_durationController.text);

      setState(() {
        _isLoading = true;
      });

      final prediction = await ImprovedMedicinePredictor.predictQuantity(
        disease: _disease,
        durationDays: duration,
        medicineName: _medicineNameController.text,
      );

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate() && _prediction != null) {
      await Provider.of<MedicineProvider>(context, listen: false).addMedicine(
        name: _medicineNameController.text,
        disease: _disease,
        durationDays: int.parse(_durationController.text),
        purchasedQuantity: int.parse(_purchasedQuantityController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
