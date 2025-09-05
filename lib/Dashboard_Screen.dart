import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;
  bool _isScannerActive = false;
  bool _isTorchOn = false;

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
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _stopScanner();
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
                                  debugPrint('Detected barcode: ${barcode.rawValue}');
                                  if (barcode.rawValue != null && 
                                      barcode.rawValue!.length == 13) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Barcode detected! Fetching information...'),
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

  Future<void> _fetchNutritionalInfo(String barcode) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Fetching info for barcode: $barcode');
      // First try with the new endpoint
      final response = await http.post(
        Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
        headers: {
          'x-app-id': nutritionixAppId,
          'x-app-key': nutritionixApiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'query': 'KitKat chocolate bar',
          'locale': 'en_US',
        }),
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
              'serving_size': '${foodData['serving_qty']} ${foodData['serving_unit']}',
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
          _showError('Product not found in database. Using generic information.');
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
                'Contains Soy'
              ],
              'ingredients': 'Sugar, wheat flour, cocoa butter, milk solids, cocoa mass, vegetable fat, emulsifier (soy lecithin), yeast, raising agent.',
            };
            _isLoading = false;
          });
          _showNutritionalInfo();
        } else {
          _showError('Failed to fetch product information: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching nutritional info: ${e.toString()}');
      _showError('Error: ${e.toString()}');
    }
  }

  List<String> _extractAllergens(Map<String, dynamic> foodData) {
    List<String> allergens = [];
    final ingredients = (foodData['nf_ingredient_statement'] ?? '').toLowerCase();
    
    final allergensToCheck = {
      'milk': 'Contains Milk',
      'egg': 'Contains Eggs',
      'fish': 'Contains Fish',
      'shellfish': 'Contains Shellfish',
      'tree nut': 'Contains Tree Nuts',
      'peanut': 'Contains Peanuts',
      'wheat': 'Contains Wheat',
      'soy': 'Contains Soy',
      'gluten': 'Contains Gluten'
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
    final servingSize = _productInfo!['serving_size'] ?? '';
    final ingredients = _productInfo!['ingredients'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
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
                _buildNutrientRow('Total Carbohydrates', nutriments['carbohydrates_100g']),
                _buildNutrientRow('Total Fat', nutriments['fat_100g']),
                _buildNutrientRow('Dietary Fiber', nutriments['fiber_100g']),
                _buildNutrientRow('Sugars', nutriments['sugars_100g']),
                _buildNutrientRow('Sodium', nutriments['sodium_100g']),
                _buildNutrientRow('Cholesterol', nutriments['cholesterol_100g']),
                if (ingredients.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ingredients,
                    style: const TextStyle(fontSize: 14),
                  ),
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
                          .map((allergen) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• $allergen',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
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
          Text(label),
          Text(displayValue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _startScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan BarCode'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upload Image clicked')),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Image'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
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
    final windowWidth = 280.0;  // Wider scanning window for better barcode capture
    final windowHeight = 120.0;  // Reduced height to match barcode proportions
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final windowPath = Path()
      ..addRect(Rect.fromCenter(
        center: center,
        width: windowWidth,
        height: windowHeight,
      ));
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      windowPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black54,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: windowWidth,
        height: windowHeight,
      ),
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
    drawCorner(Offset(center.dx - windowWidth / 2, center.dy - windowHeight / 2), true);
    drawCorner(Offset(center.dx - windowWidth / 2, center.dy - windowHeight / 2), false);
    
    drawCorner(Offset(center.dx + windowWidth / 2, center.dy - windowHeight / 2), true);
    drawCorner(Offset(center.dx + windowWidth / 2 - markerLength, center.dy - windowHeight / 2), true);
    
    drawCorner(Offset(center.dx - windowWidth / 2, center.dy + windowHeight / 2), true);
    drawCorner(Offset(center.dx - windowWidth / 2, center.dy + windowHeight / 2 - markerLength), false);
    
    drawCorner(Offset(center.dx + windowWidth / 2, center.dy + windowHeight / 2), false);
    drawCorner(Offset(center.dx + windowWidth / 2 - markerLength, center.dy + windowHeight / 2), true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}