import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
    }
  }

  Future<void> _fetchNutritionalInfo(String barcode) async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          setState(() {
            _productInfo = data['product'];
            _isLoading = false;
          });
        } else {
          _showError('Product not found');
        }
      } else {
        _showError('Failed to fetch product information');
      }
    } catch (e) {
      _showError('Error: \${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildNutritionalInfo() {
    if (_productInfo == null) return const SizedBox.shrink();

    final nutriments = _productInfo!['nutriments'] ?? {};
    final allergens = _productInfo!['allergens_tags'] ?? [];
    final productName = _productInfo!['product_name'] ?? 'Unknown Product';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(productName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          const Text(
            'Nutritional Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildNutrientRow('Calories', nutriments['energy-kcal_100g']),
          _buildNutrientRow('Proteins', nutriments['proteins_100g']),
          _buildNutrientRow('Carbohydrates', nutriments['carbohydrates_100g']),
          _buildNutrientRow('Fat', nutriments['fat_100g']),
          _buildNutrientRow('Sugars', nutriments['sugars_100g']),
          _buildNutrientRow('Fiber', nutriments['fiber_100g']),
          const SizedBox(height: 20),
          if (allergens.isNotEmpty) ...[
            const Text(
              'Allergen Warning',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              allergens.join(', ').replaceAll('en:', ''),
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isScanning = true;
                _productInfo = null;
              });
            },
            child: const Text('Scan Another Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, dynamic value) {
    final displayValue = value != null
        ? '\${value.toStringAsFixed(2)}g'
        : 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(displayValue)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white),
            SizedBox(width: 8),
            Text('Barcode Scanner'),
          ],
        ),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isScanning
          ? Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _fetchNutritionalInfo(barcode.rawValue!);
                          return;
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Point camera at food product barcode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            )
          : _buildNutritionalInfo(),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
