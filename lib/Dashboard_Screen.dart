import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  MobileScannerController? cameraController;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;
  bool _isScannerActive = false;
  bool _isTorchOn = false;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

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
                                  debugPrint(
                                    'Detected barcode: ${barcode.rawValue}',
                                  );
                                  if (barcode.rawValue != null &&
                                      barcode.rawValue!.length == 13) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Barcode detected! Fetching information...',
                                        ),
                                        duration: Duration(seconds: 1),
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

  // Image selection method
  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image selected successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
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
    final servingSize = _productInfo!['serving_size'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
                    child: Text(
                      'Serving Size: $servingSize',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Nutritional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                    const Icon(Icons.menu, size: 24, color: Colors.black54),
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

  Widget _buildNutrifyPage() {
    return const Center(
      child: Text(
        'Nutrify Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatisticsPage() {
    return const Center(
      child: Text(
        'Statistics Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

                    // Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Gender Dropdown (instead of TextField)
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      items: ["Male", "Female", "Other"]
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pet Name
                    TextField(
                      controller: petNameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Age
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
                // Validate all fields
                if (nameController.text.isEmpty ||
                    petNameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    ageController.text.isEmpty ||
                    heightController.text.isEmpty ||
                    weightController.text.isEmpty ||
                    selectedGender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields and select gender'),
                    ),
                  );
                  return;
                }

                // Email validation
                if (!emailController.text.contains('@') ||
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                    ).hasMatch(emailController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address'),
                    ),
                  );
                  return;
                }

                // Age validation
                if (int.tryParse(ageController.text) == null ||
                    int.parse(ageController.text) < 1 ||
                    int.parse(ageController.text) > 120) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid age (1-120)'),
                    ),
                  );
                  return;
                }

                // Height validation
                if (double.tryParse(heightController.text) == null ||
                    double.parse(heightController.text) <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid height (numeric, > 0)',
                      ),
                    ),
                  );
                  return;
                }

                // Weight validation
                if (double.tryParse(weightController.text) == null ||
                    double.parse(weightController.text) <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid weight (numeric, > 0)',
                      ),
                    ),
                  );
                  return;
                }

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
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
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
