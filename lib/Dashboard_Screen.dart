import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

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
  int _selectedIndex = 0;
  mobile_scanner.MobileScannerController? cameraController;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;
  bool _isScannerActive = false;
  bool _isTorchOn = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  String? _lastScannedBarcode;

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

  //aadding widgets(after)
  // Profile Page Widget
  Widget _buildProfilePage() {
    // Use the code you already have for profile page from your earlier file,
    // ensure it’s inside this class and properly completed.
    // For brevity, a minimal placeholder:
    return Center(
      child: Text(
        'Profile Page - Under construction',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  // Statistics Header Widget
  Widget _buildStatisticsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D66), Color(0xFF3ABA6E)],
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
              children: const [
                Text(
                  'Your Health Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track your nutrition journey',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Health Overview Widget
  Widget _buildHealthOverviewSection() {
    double? bmi;
    String bmiCategory = "Unknown";

    final weightStr = SigninScreen.userData['user_weight'];
    final heightStr = SigninScreen.userData['user_height'];
    final ageStr = SigninScreen.userData['user_age'];

    if (weightStr != null && heightStr != null) {
      try {
        final weight = double.parse(weightStr);
        final height = double.parse(heightStr) / 100;
        bmi = weight / (height * height);

        if (bmi < 18.5)
          bmiCategory = "Underweight";
        else if (bmi < 25)
          bmiCategory = "Normal";
        else if (bmi < 30)
          bmiCategory = "Overweight";
        else
          bmiCategory = "Obese";
      } catch (_) {}
    }

    Color bmiColor = _getBMIColor(bmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D66),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "BMI",
                value: bmi != null ? bmi.toStringAsFixed(1) : "--",
                subtitle: bmiCategory,
                icon: Icons.monitor_weight,
                color: bmiColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Weight",
                value: weightStr ?? "--",
                subtitle: "kg",
                icon: Icons.fitness_center,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Height",
                value: heightStr ?? "--",
                subtitle: "cm",
                icon: Icons.height,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Age",
                value: ageStr ?? "--",
                subtitle: "years",
                icon: Icons.cake,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.lightBlue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  // General stat card used in health overview
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Nutrition Analytics Widget
  Widget _buildNutritionAnalyticsSection() {
    // Mock data example, replace with dynamic data if available
    const calories = 1520;
    const caloriesGoal = 2000;
    const protein = 68;
    const proteinGoal = 120;
    const carbs = 180;
    const carbsGoal = 250;
    const fat = 45;
    const fatGoal = 65;

    Widget _progress(String title, int current, int goal, Color color) {
      final double progress = (current / goal).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            backgroundColor: color.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            value: progress,
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text("$current / $goal", style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Nutrition',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D66),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _progress("Calories", calories, caloriesGoal, Colors.deepOrange),
              const SizedBox(height: 12),
              _progress("Protein", protein, proteinGoal, Colors.blue),
              const SizedBox(height: 12),
              _progress("Carbs", carbs, carbsGoal, Colors.orange),
              const SizedBox(height: 12),
              _progress("Fat", fat, fatGoal, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  // Food Activity Widget
  Widget _buildFoodActivitySection() {
    // Mock values for demonstration
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D66),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildActivityCard(
                    Icons.qr_code_scanner,
                    "Products Scanned",
                    "24",
                    "This week",
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildActivityCard(
                    Icons.warning,
                    "Allergen Alerts",
                    "3",
                    "Avoided",
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActivityCard(
                    Icons.health_and_safety,
                    "Healthy Choices",
                    "18",
                    "This week",
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildActivityCard(
                    Icons.restaurant_menu,
                    "Diet Days",
                    "12",
                    "Followed",
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Diet Progress Widget
  Widget _buildDietProgressSection() {
    final goal = SigninScreen.userData['diet_goal'] ?? "Not Set";
    final currentWeight = SigninScreen.userData['user_weight'] ?? "--";
    final targetWeight = SigninScreen.userData['target_weight'] ?? "--";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D66),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Goal: $goal",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Text(
                      "Active",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text("Current Weight"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          targetWeight,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text("Target Weight"),
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

  // Weekly Insights Widget
  Widget _buildWeeklyInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D66),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInsightItem(
                Icons.check_circle,
                "Great Progress!",
                "You've maintained your diet plan for 5 consecutive days.",
                Colors.green,
              ),
              const Divider(height: 20),
              _buildInsightItem(
                Icons.fitness_center,
                "Protein Goal",
                "You're 15% below your protein goal. Add more lean meat or beans.",
                Colors.orange,
              ),
              const Divider(height: 20),
              _buildInsightItem(
                Icons.water_drop,
                "Stay Hydrated",
                "Remember to drink 8 glasses of water daily.",
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
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

  // ----------- BEGIN: Enhanced Home Page Widget ------------
  Widget _buildEnhancedHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Welcome to MindSprint! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          const Text(
            'Ready to scan and eat healthy?',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 20),
          if (_lastScannedBarcode != null)
            Container(
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
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _selectImageFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E8B57),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF2E8B57), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.upload_file, size: 24),
              label: const Text(
                "Upload Food Image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_selectedImage != null)
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
                              backgroundColor: Colors.red,
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
          if (_isLoading)
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
      ),
    );
  }
  // ----------- END: Enhanced Home Page Widget ------------

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
                ].map(
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
                ),
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
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        'Your Current Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Goal: ${SigninScreen.userData['diet_goal'] ?? 'Not set'}',
                    style: TextStyle(color: Colors.blue),
                  ),
                  if (SigninScreen.userData['diet_type'] != null)
                    Text(
                      'Diet Type: ${SigninScreen.userData['diet_type']}',
                      style: TextStyle(color: Colors.blue),
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
                        side: BorderSide(color: Colors.blue!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Update My Plan',
                        style: TextStyle(
                          color: Colors.blue,
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

  // ---------- REST OF YOUR SCREEN BUILDERS ----------
  // (insert your previously used _buildNutrifyPage, _buildStatisticsPage, _buildProfilePage, etc.)
  // ... for brevity, all other widgets from your script above (unchanged) ...

  // --------- Helper & Action Methods -------------
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
                                final List<mobile_scanner.Barcode> barcodes =
                                    capture.barcodes;
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
                                        content: Text(
                                          'Barcode detected: ${barcode.rawValue}',
                                        ),
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
                            style: TextStyle(color: Colors.green, fontSize: 14),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scanImage(File imageFile) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(
        inputImage,
      );
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

  Future<void> _fetchNutritionalInfo(String barcode) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      debugPrint('Fetching info for barcode: $barcode');
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
          final foodData = data['foods'];
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
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF2E8B57),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                      ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  const SizedBox(height: 20),
                  if (servingSize.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Serving Size: $servingSize'),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    ...allergens.map(
                      (allergen) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $allergen',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
            displayValue,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  // --- Add your other widgets here (Nutrify, Stats, Profile) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindSprint - Nutrition Tracker'),
        automaticallyImplyLeading: false,
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

// --------------- Overlay Scanner Painter -----------------
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final windowWidth = 280.0;
    final windowHeight = 120.0;
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
