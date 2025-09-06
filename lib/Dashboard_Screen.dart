import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'screens/diet_plan_screen.dart';
import 'screens/help_screen.dart';
import 'screens/history_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/settings_screen.dart';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // Bottom navigation state
  int _selectedIndex = 0;

  // Scanner state with lifecycle management
  mobile_scanner.MobileScannerController? cameraController;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;
  bool _isScannerActive = false;
  bool _isTorchOn = false;


  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  String? _lastScannedBarcode;

  // Nutritionix API credentials
  final String nutritionixAppId = '2f699f85';
  final String nutritionixApiKey = 'becba1a817e2897f16b967f7016bce6c';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _stopScanner();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopScanner();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildEnhancedHomePage();
      case 1:
        return _buildNutrifyPage();
      case 2:
        return _buildStatisticsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildEnhancedHomePage();
    }
  }

  void _initializeCamera() {
    if (cameraController != null) return;

    cameraController = mobile_scanner.MobileScannerController(
      detectionSpeed: mobile_scanner.DetectionSpeed.noDuplicates,
      facing: mobile_scanner.CameraFacing.back,
      formats: [mobile_scanner.BarcodeFormat.ean13],
      returnImage: false,
      torchEnabled: _isTorchOn,
    );
    setState(() {
      _isScannerActive = true;
    });
  }

  void _stopScanner() {
    if (!mounted) return;
    setState(() {
      _isScannerActive = false;
      _isTorchOn = false;
    });
    cameraController?.stop();
    cameraController?.dispose();
    cameraController = null;
  }

  Future<void> _scanImage(File imageFile) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
      
      if (barcodes.isNotEmpty) {
        for (final barcode in barcodes) {
          debugPrint('Detected barcode from image: ${barcode.rawValue}');
          if (barcode.rawValue != null && barcode.rawValue!.length == 13) {
            setState(() {
              _lastScannedBarcode = barcode.rawValue;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Barcode detected: ${barcode.rawValue}'),
                duration: const Duration(seconds: 2),
              ),
            );
            await _fetchNutritionalInfo(barcode.rawValue!);
            return;
          }
        }
        _showError('No valid barcode found in image');
      } else {
        _showError('No barcode detected in image');
      }
    } catch (e) {
      debugPrint('Error scanning image: $e');
      _showError('Error scanning image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndScanImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _scanImage(_selectedImage!);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _startScanner() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      _initializeCamera();

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return WillPopScope(
              onWillPop: () async {
                _stopScanner();
                return true;
              },
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Scan Barcode'),
                  actions: [
                    IconButton(
                      icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _isTorchOn = !_isTorchOn;
                          cameraController?.toggleTorch();
                        });
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          if (_isScannerActive && cameraController != null)
                            mobile_scanner.MobileScanner(
                              controller: cameraController!,
                              onDetect: (capture) {
                                final List<mobile_scanner.Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  debugPrint(
                                    'Detected barcode: ${barcode.rawValue}',
                                  );
                                  if (barcode.rawValue != null &&
                                      barcode.rawValue!.length == 13) {
                                    if (!mounted) return;
                                    setState(() {
                                      _lastScannedBarcode = barcode.rawValue;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(


                                      SnackBar(
                                        content: Text('Barcode detected: ${barcode.rawValue}'),
                                        duration: const Duration(seconds: 2),


                                      ),
                                    );
                                    Navigator.pop(context);
                                    _fetchNutritionalInfo(barcode.rawValue!);
                                    return;
                                  }
                                }
                              },
                            ),
                          CustomPaint(
                            painter: ScannerOverlayPainter(),
                            child: const SizedBox.expand(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.black54,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Point camera at food product barcode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Align barcode within the frame',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ).whenComplete(() {
        _stopScanner();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to scan barcodes'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Image selection and scanning method
  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = true;
        });
        
        await _scanImage(_selectedImage!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // QR Scanner functionality with advanced Nutritionix API
  Future<void> _fetchNutritionalInfo(String barcode) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Fetching info for barcode: $barcode');
      // Try with Nutritionix API
      final response = await http.post(
        Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
        headers: {
          'x-app-id': nutritionixAppId,
          'x-app-key': nutritionixApiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'query': 'KitKat chocolate bar', 'locale': 'en_US'}),
      );

      if (!mounted) return;

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final foodData = data['foods'][0];
          debugPrint('Found food data: ${json.encode(foodData)}');
          setState(() {
            _productInfo = {
              'product_name': foodData['food_name'] ?? 'Unknown Product',
              'brand': foodData['brand_name'] ?? 'Unknown Brand',
              'serving_size':
                  '${foodData['serving_qty']} ${foodData['serving_unit']}',
              'nutriments': {
                'energy-kcal_100g': foodData['nf_calories'],
                'proteins_100g': foodData['nf_protein'],
                'carbohydrates_100g': foodData['nf_total_carbohydrate'],
                'fat_100g': foodData['nf_total_fat'],
                'fiber_100g': foodData['nf_dietary_fiber'],
                'sugars_100g': foodData['nf_sugars'],
                'sodium_100g': foodData['nf_sodium'],
                'cholesterol_100g': foodData['nf_cholesterol'],
              },
              'allergens_tags': _extractAllergens(foodData),
              'ingredients': foodData['nf_ingredient_statement'] ?? '',
            };
            _isLoading = false;
          });
          _showNutritionalInfo();
        } else {
          _showError('Product not found');
        }
      } else {
        debugPrint('API Error Response: ${response.body}');
        if (response.statusCode == 404) {
          _showError(
            'Product not found in database. Using generic information.',
          );
          // Use generic KitKat information as fallback
          setState(() {
            _productInfo = {
              'product_name': 'KitKat',
              'brand': 'Nestlé',
              'serving_size': '1 bar (45g)',
              'nutriments': {
                'energy-kcal_100g': 518,
                'proteins_100g': 6.1,
                'carbohydrates_100g': 61.9,
                'fat_100g': 26.8,
                'fiber_100g': 1.8,
                'sugars_100g': 49.2,
                'sodium_100g': 90,
                'cholesterol_100g': 12.5,
              },
              'allergens_tags': [
                'Contains Milk',
                'Contains Wheat',
                'May contain Nuts',
                'Contains Soy',
              ],
              'ingredients':
                  'Sugar, wheat flour, cocoa butter, milk solids, cocoa mass, vegetable fat, emulsifier (soy lecithin), yeast, raising agent.',
            };
            _isLoading = false;
          });
          _showNutritionalInfo();
        } else {
          _showError(
            'Failed to fetch product information: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching nutritional info: ${e.toString()}');
      _showError('Error: ${e.toString()}');
    }
  }

  List<String> _extractAllergens(Map<String, dynamic> foodData) {
    List<String> allergens = [];
    final ingredients = (foodData['nf_ingredient_statement'] ?? '')
        .toLowerCase();

    final allergensToCheck = {
      'milk': 'Contains Milk',
      'egg': 'Contains Eggs',
      'fish': 'Contains Fish',
      'shellfish': 'Contains Shellfish',
      'tree nut': 'Contains Tree Nuts',
      'peanut': 'Contains Peanuts',
      'wheat': 'Contains Wheat',
      'soy': 'Contains Soy',
      'gluten': 'Contains Gluten',
    };

    allergensToCheck.forEach((key, value) {
      if (ingredients.contains(key)) {
        allergens.add(value);
      }
    });

    return allergens;
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Test KitKat',
          onPressed: () {
            _fetchNutritionalInfo('8901058012323'); // Test with KitKat barcode
          },
        ),
      ),
    );
  }

  void _showNutritionalInfo() {
    if (!mounted || _productInfo == null) return;

    final nutriments = _productInfo!['nutriments'] ?? {};
    final allergens = _productInfo!['allergens_tags'] ?? [];
    final productName = _productInfo!['product_name'] ?? 'Unknown Product';
    final brand = _productInfo!['brand'] ?? '';
    final ingredients = _productInfo!['ingredients'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(

          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF2E8B57),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),

          padding: const EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  productName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (brand.isNotEmpty)
                  Text(
                    brand,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 20),
                if (servingSize.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),

                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),

              ),

      

                const SizedBox(height: 10),
                _buildNutrientRow('Calories', nutriments['energy-kcal_100g']),
                _buildNutrientRow('Protein', nutriments['proteins_100g']),
                _buildNutrientRow(
                  'Total Carbohydrates',
                  nutriments['carbohydrates_100g'],
                ),
                _buildNutrientRow('Total Fat', nutriments['fat_100g']),
                _buildNutrientRow('Dietary Fiber', nutriments['fiber_100g']),
                _buildNutrientRow('Sugars', nutriments['sugars_100g']),
                _buildNutrientRow('Sodium', nutriments['sodium_100g']),
                _buildNutrientRow(
                  'Cholesterol',
                  nutriments['cholesterol_100g'],
                ),
                if (ingredients.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(ingredients, style: const TextStyle(fontSize: 14)),
                ],
                if (allergens.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Allergen Warning',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,

                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // Food Image and Info
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (brand.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  brand,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Description
                        if (ingredients.isNotEmpty) ...[
                          Text(
                            ingredients.length > 150
                                ? '${ingredients.substring(0, 150)}...'
                                : ingredients,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Nutrition Facts Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutritionCard(
                                '${(nutriments['carbohydrates_100g'] ?? 0).toStringAsFixed(0)}g',
                                'Carbs',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildNutritionCard(
                                '${(nutriments['proteins_100g'] ?? 0).toStringAsFixed(0)}g',
                                'Proteins',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildNutritionCard(
                                '${(nutriments['fat_100g'] ?? 0).toStringAsFixed(0)}g',
                                'Fats',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildNutritionCard(
                                '${(nutriments['sugars_100g'] ?? 0).toStringAsFixed(0)}g',
                                'Sugars',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Calories Section
                        if (nutriments['energy-kcal_100g'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${nutriments['energy-kcal_100g'].toStringAsFixed(0)} Calories',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],

                        // Allergen Warning
                        if (allergens.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.red[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Allergen Warning',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...allergens
                                    .map(
                                      (allergen) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '• $allergen',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],

                        // Check Recipe Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recipe feature coming soon!'),
                                  backgroundColor: Color(0xFF2E8B57),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8B57),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Text(
                              'CHECK THE RECIPE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
=======
                      children: allergens
                          .map(
                            (allergen) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '• $allergen',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          )
                          .toList(),

                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildNutritionCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),

  Widget _buildNutrientRow(String label, dynamic value) {
    String displayValue;
    if (value == null) {
      displayValue = 'N/A';
    } else {
      String unit = 'g';
      if (label == 'Calories') {
        unit = 'kcal';
      } else if (label == 'Sodium' || label == 'Cholesterol') {
        unit = 'mg';
      }
      displayValue = '${value.toStringAsFixed(1)}$unit';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [

          // Header Section

          // Welcome Header
          const Text(
            'Welcome to MindSprint! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ready to scan and eat healthy?',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 20),

          // Last Scanned Barcode
          if (_lastScannedBarcode != null) Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Scanned Barcode:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _lastScannedBarcode!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Main Scan Button

          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showNavigationDrawer(context),
                      child: const Icon(
                        Icons.menu,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Let's Check Food",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),
                const Text(
                  "Nutrition & Calories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E8B57),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select food type to see calories",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 25),

                // Food Category Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryIcon(Icons.local_dining, "Fast Food", false),
                    _buildCategoryIcon(Icons.restaurant, "Vegetables", true),
                    _buildCategoryIcon(Icons.local_bar, "Drinks", false),
                    _buildCategoryIcon(
                      Icons.shopping_basket,
                      "Groceries",
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Food Cards Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFoodCard(
                        "Vegetables &\nBeans",
                        "43 Calories",
                        Colors.green[100]!,
                        Icons.eco,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFoodCard(
                        "Vegetables &\nMeat",
                        "43 Calories",
                        Colors.orange[100]!,
                        Icons.restaurant_menu,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balanced Diet Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Balanced Diet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Stay healthy and young by\ntaking a balanced diet!",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E8B57),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                "Learn More",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=150&h=150&fit=crop',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Quick Access Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quick Access",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAccessButton(
                            Icons.history,
                            "History",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessButton(
                            Icons.settings,
                            "Settings",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessButton(
                            Icons.help,
                            "Help",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessButton(
                            Icons.info,
                            "Details",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProductDetailsScreen(
                                      productName: "Sample Product",
                                      barcode: "123456789012",
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Scan Button
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _startScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, size: 24),
                    label: const Text(
                      "Scan Food Barcode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Upload Image Button
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _selectImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E8B57),
                      elevation: 0,
                      side: const BorderSide(
                        color: Color(0xFF2E8B57),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file, size: 24),
                    label: const Text(
                      "Upload Food Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected Image Display
          if (_selectedImage != null) ...[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Image:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectImageFromGallery,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Change'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8B57),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Remove'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Loading Indicator
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E8B57),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: Color(0xFF2E8B57),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(
    String title,
    String calories,
    Color backgroundColor,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    calories,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2E8B57).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF2E8B57)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showNavigationDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Quick Navigation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Options
            _buildDrawerItem(
              Icons.history,
              'Scan History',
              'View your previous scans',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.settings,
              'Settings',
              'App preferences & account',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.help_outline,
              'Help & Support',
              'FAQ and user guides',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
            _buildDrawerItem(
              Icons.info_outline,
              'Product Details',
              'Sample product information',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductDetailsScreen(
                      productName: "Sample Product",
                      barcode: "123456789012",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E8B57).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E8B57), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  Widget _buildNutrifyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🥗 Nutrify Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create personalized diet plans tailored to your goals and preferences',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Diet Plan Generator Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E8B57).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF2E8B57),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized Diet Plan Generator',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Get a customized meal plan based on your goals',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Features included:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...[
                      '• Personalized calorie targets',
                      '• Custom meal plans based on preferences',
                      '• Allergy and dietary restriction support',
                      '• Activity level considerations',
                      '• Macro-nutrient breakdown',
                      '• Nutrition tips and guidance',
                    ]
                    .map(
                      (feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DietPlanScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Create My Diet Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats Card (if user has existing plan)
          if (SigninScreen.userData['diet_goal'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: Colors.blue[700]),
                      const SizedBox(width: 10),
                      Text(
                        'Your Current Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Goal: ${SigninScreen.userData['diet_goal'] ?? 'Not set'}',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  if (SigninScreen.userData['diet_type'] != null)
                    Text(
                      'Diet Type: ${SigninScreen.userData['diet_type']}',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DietPlanScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Update My Plan',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStatisticsHeader(),
          const SizedBox(height: 20),

          // Health Overview Cards
          _buildHealthOverviewSection(),
          const SizedBox(height: 20),

          // Nutrition Analytics
          _buildNutritionAnalyticsSection(),
          const SizedBox(height: 20),

          // Food Activity Stats
          _buildFoodActivitySection(),
          const SizedBox(height: 20),

          // Diet Plan Progress
          _buildDietProgressSection(),
          const SizedBox(height: 20),

          // Weekly Insights
          _buildWeeklyInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Health Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your nutrition journey',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverviewSection() {
    // Calculate BMI if height and weight are available
    String? weightStr = SigninScreen.userData['user_weight'];
    String? heightStr = SigninScreen.userData['user_height'];
    double? bmi;
    String bmiCategory = 'Unknown';

    if (weightStr != null && heightStr != null) {
      try {
        double weight = double.parse(weightStr);
        double height = double.parse(heightStr) / 100; // Convert cm to m
        bmi = weight / (height * height);

        if (bmi < 18.5) {
          bmiCategory = 'Underweight';
        } else if (bmi < 25) {
          bmiCategory = 'Normal';
        } else if (bmi < 30) {
          bmiCategory = 'Overweight';
        } else {
          bmiCategory = 'Obese';
        }
      } catch (e) {
        // Handle parsing errors
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'BMI',
                value: bmi != null ? bmi.toStringAsFixed(1) : '--',
                subtitle: bmiCategory,
                icon: Icons.monitor_weight,
                color: _getBMIColor(bmi),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Current Weight',
                value: weightStr ?? '--',
                subtitle: 'kg',
                icon: Icons.fitness_center,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Height',
                value: heightStr ?? '--',
                subtitle: 'cm',
                icon: Icons.height,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Age',
                value: SigninScreen.userData['user_age'] ?? '--',
                subtitle: 'years',
                icon: Icons.cake,
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return const Color(0xFF03A9F4); // Light Blue
    if (bmi < 25) return const Color(0xFF4CAF50); // Green
    if (bmi < 30) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  Widget _buildNutritionAnalyticsSection() {
    // Mock data for demonstration - in a real app, this would come from actual tracking
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Nutrition',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNutritionProgressBar(
                'Calories',
                1520,
                2000,
                const Color(0xFFFF5722),
              ),
              const SizedBox(height: 16),
              _buildNutritionProgressBar(
                'Protein',
                68,
                120,
                const Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),
              _buildNutritionProgressBar(
                'Carbs',
                180,
                250,
                const Color(0xFFFF9800),
              ),
              const SizedBox(height: 16),
              _buildNutritionProgressBar(
                'Fat',
                45,
                65,
                const Color(0xFF9C27B0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionProgressBar(
    String nutrient,
    int current,
    int target,
    Color color,
  ) {
    double progress = (current / target).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nutrient,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(
              '$current / $target',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildFoodActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActivityItem(
                      icon: Icons.qr_code_scanner,
                      title: 'Products Scanned',
                      value: '24',
                      subtitle: 'This week',
                      color: const Color(0xFF2E8B57),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActivityItem(
                      icon: Icons.warning_amber,
                      title: 'Allergen Alerts',
                      value: '3',
                      subtitle: 'Avoided',
                      color: const Color(0xFFFF5722),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActivityItem(
                      icon: Icons.favorite,
                      title: 'Healthy Choices',
                      value: '18',
                      subtitle: 'This week',
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActivityItem(
                      icon: Icons.restaurant_menu,
                      title: 'Diet Plan Days',
                      value: '12',
                      subtitle: 'Followed',
                      color: const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDietProgressSection() {
    String dietGoal = SigninScreen.userData['diet_goal'] ?? 'Not Set';
    String currentWeight = SigninScreen.userData['current_weight'] ?? '--';
    String targetWeight = SigninScreen.userData['target_weight'] ?? '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet Plan Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Goal: $dietGoal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF2E8B57),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          currentWeight,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                        const Text(
                          'Current Weight',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          targetWeight,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const Text(
                          'Target Weight',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInsightItem(
                icon: Icons.trending_up,
                title: 'Great Progress!',
                description:
                    'You\'ve maintained your diet plan for 5 consecutive days.',
                color: const Color(0xFF4CAF50),
              ),
              const Divider(height: 24),
              _buildInsightItem(
                icon: Icons.local_dining,
                title: 'Protein Goal',
                description:
                    'You\'re 15% below your daily protein target. Consider adding lean meats or beans.',
                color: const Color(0xFFFF9800),
              ),
              const Divider(height: 24),
              _buildInsightItem(
                icon: Icons.water_drop,
                title: 'Stay Hydrated',
                description:
                    'Remember to drink at least 8 glasses of water daily for optimal health.',
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    // Create controllers for editing
    final TextEditingController nameController = TextEditingController();
    final TextEditingController petNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController allergicController = TextEditingController();
    final TextEditingController diseaseController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String? selectedGender = SigninScreen.userData['gender'];

    // Populate controllers with existing data
    nameController.text = SigninScreen.userData['user_name'] ?? '';
    petNameController.text = SigninScreen.userData['user_pet_name'] ?? '';
    emailController.text = SigninScreen.userData['user_email'] ?? '';
    ageController.text = SigninScreen.userData['user_age'] ?? '';
    heightController.text = SigninScreen.userData['user_height'] ?? '';
    weightController.text = SigninScreen.userData['user_weight'] ?? '';
    allergicController.text = SigninScreen.userData['user_allergic'] ?? '';
    diseaseController.text = SigninScreen.userData['user_disease'] ?? '';
    descriptionController.text =
        SigninScreen.userData['user_description'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Basic Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(
                        text: selectedGender ?? "Not set",
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: petNameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Health Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      // Removed duplicate gender display from Health Information section
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: allergicController,
                      decoration: const InputDecoration(
                        labelText: 'Allergic to',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: diseaseController,
                      decoration: const InputDecoration(
                        labelText: 'Any disease',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Update Button
            ElevatedButton(
              onPressed: () {
                // Update the stored data
                SigninScreen.userData['user_name'] = nameController.text;
                SigninScreen.userData['user_pet_name'] = petNameController.text;
                SigninScreen.userData['user_email'] = emailController.text;
                SigninScreen.userData['user_age'] = ageController.text;
                SigninScreen.userData['user_height'] = heightController.text;
                SigninScreen.userData['user_weight'] = weightController.text;
                SigninScreen.userData['user_gender'] = selectedGender ?? '';
                SigninScreen.userData['user_allergic'] =
                    allergicController.text;
                SigninScreen.userData['user_disease'] = diseaseController.text;
                SigninScreen.userData['user_description'] =
                    descriptionController.text;

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Refresh the page by calling setState
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindSprint - Nutrition Tracker'),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final windowWidth =
        280.0; // Wider scanning window for better barcode capture
    final windowHeight = 120.0; // Reduced height to match barcode proportions
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final windowPath = Path()
      ..addRect(
        Rect.fromCenter(
          center: center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      windowPath,
    );

    canvas.drawPath(overlayPath, Paint()..color = Colors.black54);

    canvas.drawRect(
      Rect.fromCenter(center: center, width: windowWidth, height: windowHeight),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final markerLength = 20.0;
    final markerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    void drawCorner(Offset start, bool isHorizontal) {
      canvas.drawLine(
        start,
        Offset(
          start.dx + (isHorizontal ? markerLength : 0),
          start.dy + (isHorizontal ? 0 : markerLength),
        ),
        markerPaint,
      );
    }

    // Draw corners
    drawCorner(
      Offset(center.dx - windowWidth / 2, center.dy - windowHeight / 2),
      true,
    );
    drawCorner(
      Offset(center.dx - windowWidth / 2, center.dy - windowHeight / 2),
      false,
    );

    drawCorner(
      Offset(center.dx + windowWidth / 2, center.dy - windowHeight / 2),
      true,
    );
    drawCorner(
      Offset(
        center.dx + windowWidth / 2 - markerLength,
        center.dy - windowHeight / 2,
      ),
      true,
    );

    drawCorner(
      Offset(center.dx - windowWidth / 2, center.dy + windowHeight / 2),
      true,
    );
    drawCorner(
      Offset(
        center.dx - windowWidth / 2,
        center.dy + windowHeight / 2 - markerLength,
      ),
      false,
    );

    drawCorner(
      Offset(center.dx + windowWidth / 2, center.dy + windowHeight / 2),
      false,
    );
    drawCorner(
      Offset(
        center.dx + windowWidth / 2 - markerLength,
        center.dy + windowHeight / 2,
      ),
      true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
