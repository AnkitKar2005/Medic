import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/medicine_provider.dart';
import '../services/ocr_service.dart';
import 'medicine_disposal_screen.dart';

class MedicineUploadScreen extends StatefulWidget {
  const MedicineUploadScreen({super.key});

  @override
  State<MedicineUploadScreen> createState() => _MedicineUploadScreenState();
}

class _MedicineUploadScreenState extends State<MedicineUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  File? _selectedImage;
  String? _batchNumber;
  DateTime? _expiryDate;
  String? _medicineName;
  int? _unusedQuantity;
  bool _isProcessing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Unused Medicine'),
      ),
      body: SingleChildScrollView(
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
                      'Smart Medicine Return/Donation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload medicine image to extract batch number and expiry date using AI OCR',
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

            // Image Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_selectedImage != null) ...[
                      Image.file(
                        _selectedImage!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.change_circle),
                        label: const Text('Change Image'),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Process OCR Button
            if (_selectedImage != null && !_isProcessing)
              ElevatedButton.icon(
                onPressed: _processOCR,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Extract Details with AI OCR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                ),
              ),

            if (_isProcessing)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing image with AI OCR...'),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Medicine Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              onChanged: (value) => _medicineName = value,
            ),
            const SizedBox(height: 16),

            // Batch Number
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Batch Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                helperText: 'Extracted from image or enter manually',
              ),
              initialValue: _batchNumber,
              onChanged: (value) => _batchNumber = value,
            ),
            const SizedBox(height: 16),

            // Expiry Date
            InkWell(
              onTap: _selectExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  helperText: 'Extracted from image or select manually',
                ),
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Select expiry date',
                  style: TextStyle(
                    color: _expiryDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Unused Quantity
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Unused Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                helperText: 'Number of unused units',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _unusedQuantity = int.tryParse(value),
            ),
            const SizedBox(height: 24),

            // Continue Button
            if (_medicineName != null &&
                _batchNumber != null &&
                _expiryDate != null &&
                _unusedQuantity != null)
              ElevatedButton(
                onPressed: _continueToDisposal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Return/Donation',
                  style: TextStyle(fontSize: 18),
                ),
              ),

            const SizedBox(height: 24),

            // OCR Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'AI OCR Technology',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app uses Google ML Kit Text Recognition to automatically extract batch numbers and expiry dates from medicine images. The OCR model processes text patterns and dates to reduce manual data entry.',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _batchNumber = null;
        _expiryDate = null;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _batchNumber = null;
        _expiryDate = null;
      });
    }
  }

  Future<void> _processOCR() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final ocrText = await _ocrService.extractText(_selectedImage!.path);
      final batch = _ocrService.extractBatchNumber(ocrText);
      final expiry = _ocrService.extractExpiryDate(ocrText);

      setState(() {
        _batchNumber = batch;
        _expiryDate = expiry;
        _isProcessing = false;
      });

      if (batch != null || expiry != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Extracted: ${batch != null ? "Batch: $batch" : ""} ${expiry != null ? "Expiry: ${expiry.day}/${expiry.month}/${expiry.year}" : ""}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract details. Please enter manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OCR processing failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _continueToDisposal() {
    if (_medicineName != null &&
        _batchNumber != null &&
        _expiryDate != null &&
        _unusedQuantity != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicineDisposalScreen(
            medicineName: _medicineName!,
            batchNumber: _batchNumber!,
            expiryDate: _expiryDate!,
            unusedQuantity: _unusedQuantity!,
            imagePath: _selectedImage?.path,
          ),
        ),
      );
    }
  }
}
