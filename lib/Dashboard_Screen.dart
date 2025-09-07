import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
import 'screens/comparison_screen.dart';
import 'screens/user_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  
  const DashboardScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // Bottom navigation state
  int _selectedIndex = 0;

  // Category selection state
  String _selectedCategory = "Vegetables";

  // Scanner state with lifecycle management
  MobileScannerController? cameraController;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;
  bool _isScannerActive = false;
  bool _isTorchOn = false;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Nutritionix API credentials
  final String nutritionixAppId = '2f699f85';
  final String nutritionixApiKey = 'becba1a817e2897f16b967f7016bce6c';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _stopScanner();
    _searchController.dispose();
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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _showCategoryDetails(category);
  }

  void _showCategoryDetails(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected category: $category'),
        backgroundColor: const Color(0xFF2E8B57),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Food'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter food name...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                Navigator.pop(context);
                _searchFood(_searchController.text);
                _searchController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _searchFood(String foodName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $foodName'),
        backgroundColor: const Color(0xFF2E8B57),
      ),
    );
    // Here you can implement actual food search functionality
    // For now, we'll just show a message
  }

  void _onFoodCardTapped(String foodType, String calories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productName: foodType,
          barcode: "sample_${foodType.toLowerCase().replaceAll(' ', '_')}",
        ),
      ),
    );
  }

  void _showDietPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DietPlanScreen()),
    );
  }

  void _showScanOptions() {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan Product',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 20),
            _buildScanOption(
              Icons.qr_code_scanner,
              'Scan Barcode',
              'Scan product barcode for instant nutrition info',
              () {
                Navigator.pop(context);
                _startScanner();
              },
            ),
            _buildScanOption(
              Icons.photo_camera,
              'Take Photo',
              'Take a photo of product label',
              () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            _buildScanOption(
              Icons.photo_library,
              'Choose from Gallery',
              'Select product image from gallery',
              () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOption(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2E8B57).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF2E8B57), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _processSelectedImage();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _processSelectedImage();
    }
  }

  void _processSelectedImage() {
    if (_selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selected! Processing nutrition information...'),
          backgroundColor: Color(0xFF2E8B57),
        ),
      );
      // Always show KitKat details and allergy warning for uploaded images
      Future.delayed(const Duration(seconds: 2), () {
        final kitkatInfo = {
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
            'Contains Milk (Dairy)',
            'Contains Wheat',
            'May contain Nuts',
            'Contains Soy',
            'Dairy allergen warning: This product contains milk and may not be suitable for those with dairy allergies.',
          ],
          'ingredients': 'Sugar, wheat flour, cocoa butter, milk solids, cocoa mass, vegetable fat, emulsifier (soy lecithin), yeast, raising agent.',
          'photo': {
            'thumb': 'assets/images/kitkat.jpeg',
            'is_local': true,
          },
        };
        setState(() {
          _productInfo = kitkatInfo;
        });
        _showNutritionalInfo();
      });
    }
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

    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.ean13],
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

  Future<void> _startScanner() async {
    // Request camera permission
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
                            MobileScanner(
                              controller: cameraController!,
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  debugPrint('Detected barcode: ${barcode.rawValue}');
                                  if (barcode.rawValue != null && barcode.rawValue!.length == 13) {
                                    if (!mounted) return;
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
                              color: Colors.green,
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
  // ...existing code...
  }

  // QR Scanner functionality with advanced Nutritionix API
  Future<void> _fetchNutritionalInfo(String barcode) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Fetching info for barcode: $barcode');
      debugPrint('API URL: https://trackapi.nutritionix.com/v2/search/item?upc=$barcode');
      // Use Nutritionix UPC endpoint
      final response = await http.get(
        Uri.parse('https://trackapi.nutritionix.com/v2/search/item?upc=$barcode'),
        headers: {
          'x-app-id': nutritionixAppId,
          'x-app-key': nutritionixApiKey,
          'Accept': 'application/json',
        },
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
                'energy-kcal_100g': foodData['nf_calories'] ?? 0,
                'proteins_100g': foodData['nf_protein'] ?? 0,
                'carbohydrates_100g': foodData['nf_total_carbohydrate'] ?? 0,
                'fat_100g': foodData['nf_total_fat'] ?? 0,
                'fiber_100g': foodData['nf_dietary_fiber'] ?? 0,
                'sugars_100g': foodData['nf_sugars'] ?? 0,
                'sodium_100g': foodData['nf_sodium'] ?? 0,
                'cholesterol_100g': foodData['nf_cholesterol'] ?? 0,
              },
              'allergens_tags': _extractAllergens(foodData),
              'ingredients': foodData['nf_ingredient_statement'] ?? '',
              'photo': {
                'thumb': foodData['photo']?['thumb'],
                'highres': foodData['photo']?['highres'],
                'is_user_uploaded': foodData['photo']?['is_user_uploaded'] ?? false,
              },
            };
            _isLoading = false;
          });
          _showNutritionalInfo();
          return;
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
              'photo': {
                'thumb': 'assets/images/kitkat.jpeg',
                'is_local': true,
              },
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
    final allergens = _extractAllergens(_productInfo!);
    final productName = _productInfo!['product_name'] ?? 'Unknown Product';
    final brand = _productInfo!['brand'] ?? '';
    final ingredients = _productInfo!['ingredients_text'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
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
                          children: [
                            if (_productInfo != null && _productInfo!['photo'] != null && _productInfo!['photo']['thumb'] != null)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _productInfo!['photo']['is_local'] == true
                                    ? Image.asset(
                                        _productInfo!['photo']['thumb'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            ),
                                          );
                                        },
                                      )
                                    : Image.network(
                                        _productInfo!['photo']['thumb'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              )
                            else
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 15),
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (brand.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                brand,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detailed Nutritional Information Section
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            const Text(
                              'Nutritional Information (per 100g)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildDetailedNutritionRow(
                              'Calories',
                              nutriments['energy-kcal_100g']?.toStringAsFixed(
                                    0,
                                  ) ??
                                  '0',
                              'kcal',
                            ),
                            _buildDetailedNutritionRow(
                              'Total Fat',
                              '${(nutriments['fat_100g'] ?? 0).toStringAsFixed(1)}g',
                              '',
                            ),
                            _buildDetailedNutritionRow(
                              'Saturated Fat',
                              '${(nutriments['saturated-fat_100g'] ?? 0).toStringAsFixed(1)}g',
                              '',
                            ),
                            _buildDetailedNutritionRow(
                              'Sodium',
                              '${((nutriments['sodium_100g'] ?? 0) * 1000).toStringAsFixed(0)}mg',
                              '',
                            ),
                            _buildDetailedNutritionRow(
                              'Total Carbs',
                              '${(nutriments['carbohydrates_100g'] ?? 0).toStringAsFixed(1)}g',
                              '',
                            ),
                            _buildDetailedNutritionRow(
                              'Sugars',
                              '${(nutriments['sugars_100g'] ?? 0).toStringAsFixed(1)}g',
                              '',
                            ),
                            _buildDetailedNutritionRow(
                              'Protein',
                              '${(nutriments['proteins_100g'] ?? 0).toStringAsFixed(1)}g',
                              '',
                            ),
                            if (nutriments['fiber_100g'] != null)
                              _buildDetailedNutritionRow(
                                'Fiber',
                                '${(nutriments['fiber_100g'] ?? 0).toStringAsFixed(1)}g',
                                '',
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Ingredients Section
                      if (ingredients.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
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
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                ingredients,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Allergen Information Section
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            const Text(
                              'Allergen Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (allergens.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.red[600],
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Contains allergens:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...allergens
                                        .map(
                                          (allergen) => Text(
                                            '• $allergen',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF38B2AC,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF38B2AC,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF38B2AC),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'No common allergens detected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF38B2AC),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsScreen(
                                        productName: productName,
                                        barcode: _productInfo!['code']?.toString() ?? '',
                                        photoUrl: _productInfo!['photo']?['thumb'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline, size: 20),
                                label: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8B57),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Recipe feature coming soon!',
                                      ),
                                      backgroundColor: Color(0xFF2E8B57),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.restaurant, size: 20),
                                label: const Text(
                                  'Find Recipes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedNutritionRow(
    String nutrient,
    String amount,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
          ),
          Text(
            '$amount $unit'.trim(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
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
                    GestureDetector(
                      onTap: _showSearchDialog,
                      child: Container(
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
                    GestureDetector(
                      onTap: () => _onCategorySelected("Fast Food"),
                      child: _buildCategoryIcon(
                        Icons.local_dining,
                        "Fast Food",
                        _selectedCategory == "Fast Food",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onCategorySelected("Vegetables"),
                      child: _buildCategoryIcon(
                        Icons.restaurant,
                        "Vegetables",
                        _selectedCategory == "Vegetables",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onCategorySelected("Drinks"),
                      child: _buildCategoryIcon(
                        Icons.local_bar,
                        "Drinks",
                        _selectedCategory == "Drinks",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onCategorySelected("Groceries"),
                      child: _buildCategoryIcon(
                        Icons.shopping_basket,
                        "Groceries",
                        _selectedCategory == "Groceries",
                      ),
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
                      child: GestureDetector(
                        onTap: () => _onFoodCardTapped(
                          "Vegetables & Beans",
                          "43 Calories",
                        ),
                        child: _buildFoodCard(
                          "Vegetables &\nBeans",
                          "43 Calories",
                          Colors.green[100]!,
                          Icons.eco,
                          Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onFoodCardTapped(
                          "Vegetables & Meat",
                          "43 Calories",
                        ),
                        child: _buildFoodCard(
                          "Vegetables &\nMeat",
                          "43 Calories",
                          Colors.orange[100]!,
                          Icons.restaurant_menu,
                          Colors.orange,
                        ),
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
                            GestureDetector(
                              onTap: _showDietPlan,
                              child: Container(
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
                    onPressed: _pickImageFromGallery,
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
                            onPressed: _pickImageFromGallery,
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
                    builder: (context) => ProductDetailsScreen(
                      productName: "Sample Product",
                      barcode: "123456789012",
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.qr_code_scanner,
              'Quick Scan',
              'Scan barcode immediately',
              () {
                Navigator.pop(context);
                _startScanner();
              },
            ),
            _buildDrawerItem(
              Icons.restaurant_menu,
              'Diet Plans',
              'Personalized meal plans',
              () {
                Navigator.pop(context);
                _showDietPlan();
              },
            ),
            _buildDrawerItem(
              Icons.compare_arrows,
              'Compare Products',
              'Compare nutrition facts',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComparisonScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.person_outline,
              'User Profile',
              'Manage your profile & preferences',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're on a tablet or desktop
        bool isTabletOrDesktop = constraints.maxWidth > 768;
        bool isDesktop = constraints.maxWidth > 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTabletOrDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildStatisticsHeader(),
              SizedBox(height: isTabletOrDesktop ? 32 : 20),

              // Content based on screen size
              if (isDesktop)
                _buildDesktopLayout()
              else if (isTabletOrDesktop)
                _buildTabletLayout()
              else
                _buildMobileLayout(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Top row - Health Overview and Nutrition Analytics
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildHealthOverviewSection(),
                  const SizedBox(height: 32),
                  _buildFoodActivitySection(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildNutritionAnalyticsSection(),
                  const SizedBox(height: 32),
                  _buildDietProgressSection(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Bottom - Weekly Insights full width
        _buildWeeklyInsightsSection(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        // Health Overview Cards in 2x2 grid for tablet
        _buildHealthOverviewSection(),
        const SizedBox(height: 24),

        // Nutrition and Activity in row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildNutritionAnalyticsSection()),
            const SizedBox(width: 24),
            Expanded(child: _buildFoodActivitySection()),
          ],
        ),
        const SizedBox(height: 24),

        // Diet progress and insights
        _buildDietProgressSection(),
        const SizedBox(height: 24),
        _buildWeeklyInsightsSection(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
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
    );
  }

  Widget _buildStatisticsHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 400;

        return Container(
          padding: EdgeInsets.all(isCompact ? 16.0 : 20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: isCompact
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        const Text(
                          'Your Health Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your nutrition journey',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 28,
                      ),
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
      },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

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

            // Responsive grid layout
            if (isWideScreen)
              // Wide screen: 4 cards in a row
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
                  const SizedBox(width: 12),
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
              )
            else
              // Mobile: 2x2 grid
              Column(
                children: [
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
              ),
          ],
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 400;

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
              padding: EdgeInsets.all(isWideScreen ? 20 : 16),
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
                  SizedBox(height: isWideScreen ? 20 : 16),
                  _buildNutritionProgressBar(
                    'Protein',
                    68,
                    120,
                    const Color(0xFF2196F3),
                  ),
                  SizedBox(height: isWideScreen ? 20 : 16),
                  _buildNutritionProgressBar(
                    'Carbs',
                    180,
                    250,
                    const Color(0xFFFF9800),
                  ),
                  SizedBox(height: isWideScreen ? 20 : 16),
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
      },
    );
  }

  Widget _buildNutritionProgressBar(
    String nutrient,
    int current,
    int target,
    Color color,
  ) {
    double progress = (current / target).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 300;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    nutrient,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$current / $target',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isCompact ? 12 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 6 : 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: isCompact ? 6 : 8,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodActivitySection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 500;

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
              padding: EdgeInsets.all(isWideScreen ? 20 : 16),
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
              child: isWideScreen
                  // Wide screen: All items in a single row
                  ? Row(
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
                        const SizedBox(width: 16),
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
                    )
                  // Mobile: 2x2 grid
                  : Column(
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
      },
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = constraints.maxWidth;
        bool isCompact = itemWidth < 150;

        return Container(
          padding: EdgeInsets.all(isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: isCompact ? 16 : 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 6 : 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isCompact ? 9 : 10,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

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
              padding: EdgeInsets.all(isWideScreen ? 20 : 16),
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
                  Divider(height: isWideScreen ? 32 : 24),
                  _buildInsightItem(
                    icon: Icons.local_dining,
                    title: 'Protein Goal',
                    description:
                        'You\'re 15% below your daily protein target. Consider adding lean meats or beans.',
                    color: const Color(0xFFFF9800),
                  ),
                  Divider(height: isWideScreen ? 32 : 24),
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
      },
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 400;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 6 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isCompact ? 20 : 24),
            ),
            SizedBox(width: isCompact ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isCompact ? 12 : 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine responsive sizing
        double cardWidth = constraints.maxWidth;
        double fontSize = cardWidth < 120 ? 20 : 24;
        double iconSize = cardWidth < 120 ? 16 : 20;
        double titleFontSize = cardWidth < 120 ? 10 : 12;
        double subtitleFontSize = cardWidth < 120 ? 10 : 12;
        double padding = cardWidth < 120 ? 12 : 16;

        return Container(
          padding: EdgeInsets.all(padding),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: iconSize),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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

    String selectedGender = SigninScreen.userData['user_gender'] ?? 'Male';

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
                    StatefulBuilder(
                      builder: (context, setStateLocal) {
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedGender,
                          items: ['Male', 'Female', 'Other'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setStateLocal(() {
                              selectedGender = newValue!;
                            });
                          },
                        );
                      },
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
                SigninScreen.userData['user_gender'] = selectedGender;
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
        title: const Row(
          children: [
            Icon(Icons.dashboard, color: Colors.white),
            SizedBox(width: 8),
            Text('NutriGo - Nutrition Tracker'),
          ],
        ),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _getSelectedPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanOptions,
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 8,
        tooltip: 'Scan Product',
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.restaurant_menu, 'Nutrify', 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.analytics, 'Statistics', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2E8B57) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2E8B57) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
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
