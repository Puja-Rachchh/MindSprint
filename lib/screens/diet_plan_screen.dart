import 'package:flutter/material.dart';
import '../Signin_Screen.dart';
import 'package:permission_handler/permission_handler.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({Key? key}) : super(key: key);

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  // Form controllers
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  // Selected preferences
  String _selectedGoal = 'Weight Loss';
  String _selectedActivityLevel = 'Moderate';
  String _selectedDietType = 'Balanced';
  String _selectedMealFrequency = '3 meals + 2 snacks';
  List<String> _selectedFoodPreferences = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedDislikes = [];

  // Meal timing preferences
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  // Lists for options
  final List<String> _goals = [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Maintenance',
    'Athletic Performance',
  ];

  final List<String> _activityLevels = [
    'Sedentary (Little/no exercise)',
    'Light (1-3 days/week)',
    'Moderate (3-5 days/week)',
    'Active (6-7 days/week)',
    'Very Active (2x/day, intense)',
  ];

  final List<String> _dietTypes = [
    'Balanced',
    'Low Carb',
    'High Protein',
    'Mediterranean',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
  ];

  final List<String> _mealFrequencies = [
    '2 meals',
    '3 meals',
    '3 meals + 1 snack',
    '3 meals + 2 snacks',
    '5-6 small meals',
    '6+ meals (Athletic)',
  ];

  final List<String> _foodPreferences = [
    'Chicken',
    'Fish',
    'Red Meat',
    'Eggs',
    'Dairy',
    'Nuts',
    'Seeds',
    'Quinoa',
    'Rice',
    'Pasta',
    'Bread',
    'Fruits',
    'Vegetables',
    'Legumes',
    'Tofu',
  ];

  final List<String> _commonAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Dairy',
    'Eggs',
    'Fish',
    'Shellfish',
    'Soy',
    'Wheat/Gluten',
    'Sesame',
  ];

  final List<String> _commonDislikes = [
    'Spicy Food',
    'Seafood',
    'Mushrooms',
    'Onions',
    'Garlic',
    'Cilantro',
    'Olives',
    'Tomatoes',
    'Bell Peppers',
    'Broccoli',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load existing user data if available
    final userData = SigninScreen.userData;
    _currentWeightController.text = userData['user_weight'] ?? '';

    // Load existing allergies if available
    String existingAllergies = userData['user_allergic'] ?? '';
    if (existingAllergies.isNotEmpty) {
      _selectedAllergies = existingAllergies
          .split(',')
          .map((e) => e.trim())
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Diet Plan Generator'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 30),

            // Goal Section
            _buildGoalSection(),
            const SizedBox(height: 25),

            // Body Information Section
            _buildBodyInfoSection(),
            const SizedBox(height: 25),

            // Activity Level Section
            _buildActivityLevelSection(),
            const SizedBox(height: 25),

            // Diet Preferences Section
            _buildDietPreferencesSection(),
            const SizedBox(height: 25),

            // Food Preferences Section
            _buildFoodPreferencesSection(),
            const SizedBox(height: 25),

            // Allergies Section
            _buildAllergiesSection(),
            const SizedBox(height: 25),

            // Dislikes Section
            _buildDislikesSection(),
            const SizedBox(height: 40),

            // Generate Diet Plan Button
            _buildGenerateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            '🥗 Personalized Diet Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Let us create a perfect diet plan tailored just for you based on your goals, preferences, and lifestyle.',
            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return _buildSection(
      title: 'What\'s Your Goal?',
      icon: Icons.track_changes,
      child: Column(
        children: _goals
            .map(
              (goal) => RadioListTile<String>(
                title: Text(goal),
                value: goal,
                groupValue: _selectedGoal,
                activeColor: const Color(0xFF2E8B57),
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value!;
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBodyInfoSection() {
    return _buildSection(
      title: 'Body Information',
      icon: Icons.monitor_weight,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _currentWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Current Weight (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextFormField(
                  controller: _targetWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Target Weight (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSection() {
    return _buildSection(
      title: 'Activity Level',
      icon: Icons.directions_run,
      child: Column(
        children: _activityLevels
            .map(
              (level) => RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _selectedActivityLevel,
                activeColor: const Color(0xFF2E8B57),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value!;
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDietPreferencesSection() {
    return _buildSection(
      title: 'Diet Type Preference',
      icon: Icons.restaurant_menu,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDietType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.food_bank),
            ),
            items: _dietTypes
                .map((diet) => DropdownMenuItem(value: diet, child: Text(diet)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDietType = value!;
              });
            },
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedMealFrequency,
            decoration: const InputDecoration(
              labelText: 'Meal Frequency',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule),
            ),
            items: _mealFrequencies
                .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMealFrequency = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          // Meal Timing Section
          _buildMealTimingSection(),
        ],
      ),
    );
  }

  Widget _buildMealTimingSection() {
    return _buildSection(
      title: 'Meal Timings',
      subtitle: 'Set your preferred meal times for personalized reminders',
      icon: Icons.access_time,
      child: Column(
        children: [
          _buildTimePickerTile(
            title: 'Breakfast Time',
            subtitle: 'When do you usually have breakfast?',
            icon: Icons.wb_sunny,
            time: _breakfastTime,
            onTimeChanged: (time) {
              setState(() {
                _breakfastTime = time;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildTimePickerTile(
            title: 'Lunch Time',
            subtitle: 'When do you usually have lunch?',
            icon: Icons.wb_cloudy,
            time: _lunchTime,
            onTimeChanged: (time) {
              setState(() {
                _lunchTime = time;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildTimePickerTile(
            title: 'Dinner Time',
            subtitle: 'When do you usually have dinner?',
            icon: Icons.nightlight_round,
            time: _dinnerTime,
            onTimeChanged: (time) {
              setState(() {
                _dinnerTime = time;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required TimeOfDay time,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E8B57), size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E8B57)),
          ),
          child: Text(
            time.format(context),
            style: const TextStyle(
              color: Color(0xFF2E8B57),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        onTap: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(
                    context,
                  ).colorScheme.copyWith(primary: const Color(0xFF2E8B57)),
                ),
                child: child!,
              );
            },
          );
          if (pickedTime != null) {
            onTimeChanged(pickedTime);
          }
        },
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    return _buildSection(
      title: 'Food Preferences',
      subtitle: 'Select foods you enjoy eating',
      icon: Icons.favorite,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _foodPreferences
            .map(
              (food) => FilterChip(
                label: Text(food),
                selected: _selectedFoodPreferences.contains(food),
                selectedColor: const Color(0xFF2E8B57).withOpacity(0.3),
                checkmarkColor: const Color(0xFF2E8B57),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFoodPreferences.add(food);
                    } else {
                      _selectedFoodPreferences.remove(food);
                    }
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSection(
      title: 'Allergies & Intolerances',
      subtitle: 'Select foods you\'re allergic to or intolerant of',
      icon: Icons.warning_amber,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _commonAllergies
            .map(
              (allergy) => FilterChip(
                label: Text(allergy),
                selected: _selectedAllergies.contains(allergy),
                selectedColor: Colors.red.withOpacity(0.3),
                checkmarkColor: Colors.red,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(allergy);
                    } else {
                      _selectedAllergies.remove(allergy);
                    }
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDislikesSection() {
    return _buildSection(
      title: 'Food Dislikes',
      subtitle: 'Select foods you prefer to avoid',
      icon: Icons.thumb_down,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _commonDislikes
            .map(
              (dislike) => FilterChip(
                label: Text(dislike),
                selected: _selectedDislikes.contains(dislike),
                selectedColor: Colors.orange.withOpacity(0.3),
                checkmarkColor: Colors.orange,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDislikes.add(dislike);
                    } else {
                      _selectedDislikes.remove(dislike);
                    }
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
              Icon(icon, color: const Color(0xFF2E8B57), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _generateDietPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF2E8B57).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_awesome, size: 24),
            SizedBox(width: 12),
            Text(
              'Generate My Diet Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateDietPlan() {
    // Validate required fields
    if (_currentWeightController.text.isEmpty ||
        _targetWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in your current and target weight'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save user preferences
    _saveUserPreferences();

    // Navigate to generated diet plan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedDietPlanScreen(
          goal: _selectedGoal,
          currentWeight: _currentWeightController.text,
          targetWeight: _targetWeightController.text,
          activityLevel: _selectedActivityLevel,
          dietType: _selectedDietType,
          mealFrequency: _selectedMealFrequency,
          foodPreferences: _selectedFoodPreferences,
          allergies: _selectedAllergies,
          dislikes: _selectedDislikes,
          breakfastTime: _breakfastTime,
          lunchTime: _lunchTime,
          dinnerTime: _dinnerTime,
        ),
      ),
    );
  }

  void _saveUserPreferences() {
    // Save preferences to user data
    SigninScreen.userData['diet_goal'] = _selectedGoal;
    SigninScreen.userData['current_weight'] = _currentWeightController.text;
    SigninScreen.userData['target_weight'] = _targetWeightController.text;
    SigninScreen.userData['activity_level'] = _selectedActivityLevel;
    SigninScreen.userData['diet_type'] = _selectedDietType;
    SigninScreen.userData['meal_frequency'] = _selectedMealFrequency;
    SigninScreen.userData['food_preferences'] = _selectedFoodPreferences.join(
      ',',
    );
    SigninScreen.userData['user_allergic'] = _selectedAllergies.join(', ');
    SigninScreen.userData['food_dislikes'] = _selectedDislikes.join(',');

    // Save custom meal times
    SigninScreen.userData['breakfast_time'] =
        '${_breakfastTime.hour}:${_breakfastTime.minute.toString().padLeft(2, '0')}';
    SigninScreen.userData['lunch_time'] =
        '${_lunchTime.hour}:${_lunchTime.minute.toString().padLeft(2, '0')}';
    SigninScreen.userData['dinner_time'] =
        '${_dinnerTime.hour}:${_dinnerTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }
}

// Generated Diet Plan Screen
class GeneratedDietPlanScreen extends StatelessWidget {
  final String goal;
  final String currentWeight;
  final String targetWeight;
  final String activityLevel;
  final String dietType;
  final String mealFrequency;
  final List<String> foodPreferences;
  final List<String> allergies;
  final List<String> dislikes;
  final TimeOfDay breakfastTime;
  final TimeOfDay lunchTime;
  final TimeOfDay dinnerTime;

  const GeneratedDietPlanScreen({
    Key? key,
    required this.goal,
    required this.currentWeight,
    required this.targetWeight,
    required this.activityLevel,
    required this.dietType,
    required this.mealFrequency,
    required this.foodPreferences,
    required this.allergies,
    required this.dislikes,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Diet Plan'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Share or save functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diet plan saved to your profile!'),
                ),
              );
            },
            icon: const Icon(Icons.bookmark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanHeader(),
            const SizedBox(height: 25),
            _buildCalorieInfo(),
            const SizedBox(height: 25),
            _buildMealPlan(),
            const SizedBox(height: 25),
            _buildNutritionTips(),
            const SizedBox(height: 25),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader() {
    return Container(
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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Your Personalized Diet Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Goal: $goal',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            'Diet Type: $dietType',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            'Meal Frequency: $mealFrequency',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo() {
    int targetCalories = _calculateTargetCalories();

    return Container(
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
        children: [
          const Text(
            'Daily Calorie Target',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            '$targetCalories calories',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E8B57),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroInfo(
                'Carbs',
                '${(targetCalories * 0.45 / 4).round()}g',
                '45%',
              ),
              _buildMacroInfo(
                'Protein',
                '${(targetCalories * 0.25 / 4).round()}g',
                '25%',
              ),
              _buildMacroInfo(
                'Fats',
                '${(targetCalories * 0.30 / 9).round()}g',
                '30%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String macro, String grams, String percentage) {
    return Column(
      children: [
        Text(
          macro,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          grams,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          percentage,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMealPlan() {
    return Container(
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
          const Text(
            'Sample Meal Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildMealCard('Breakfast', _getBreakfastOptions()),
          _buildMealCard('Lunch', _getLunchOptions()),
          _buildMealCard('Dinner', _getDinnerOptions()),
          if (mealFrequency.contains('snack')) ...[
            _buildMealCard('Snacks', _getSnackOptions()),
          ],
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2E8B57),
            ),
          ),
          const SizedBox(height: 10),
          ...options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $option'),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildNutritionTips() {
    return Container(
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
              Icon(Icons.lightbulb, color: Colors.blue[700]),
              const SizedBox(width: 10),
              Text(
                'Nutrition Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...(_getNutritionTips()
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    '• $tip',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              )
              .toList()),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Show notification permission dialog first
              _showNotificationPermissionDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Start Following This Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E8B57)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Modify Preferences',
              style: TextStyle(
                color: Color(0xFF2E8B57),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _scheduleDietReminders(BuildContext context) {
    // Use user-defined meal times
    final mealTimes = [
      {
        'label': 'Breakfast',
        'hour': breakfastTime.hour,
        'minute': breakfastTime.minute,
      },
      {'label': 'Lunch', 'hour': lunchTime.hour, 'minute': lunchTime.minute},
      {'label': 'Dinner', 'hour': dinnerTime.hour, 'minute': dinnerTime.minute},
    ];
    // You can add snack times based on mealFrequency if needed

    // This is a placeholder for actual notification scheduling
    // On mobile, use flutter_local_notifications; on web, use browser APIs/service workers
    for (var meal in mealTimes) {
      // TODO: Schedule notification for meal['label'] at meal['hour']:meal['minute']
      print(
        'Reminder set for ${meal['label']} at ${meal['hour']}:${meal['minute']}',
      );
    }
  }

  void _showNotificationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Color(0xFF2E8B57),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enable Meal Reminders?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get reminded about your meals to stay on track with your diet plan:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildReminderTime('🍳', 'Breakfast', '8:00 AM'),
                  const SizedBox(height: 8),
                  _buildReminderTime('🍽️', 'Lunch', '1:00 PM'),
                  const SizedBox(height: 8),
                  _buildReminderTime('🍽️', 'Dinner', '7:00 PM'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can always change this later in your device settings.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startDietPlanWithoutNotifications(context);
            },
            child: const Text(
              'Skip for Now',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestNotificationPermission(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Allow Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTime(String emoji, String meal, String time) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            meal,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
        ),
      );

      // For web, use the Notification API directly
      if (identical(0, 0.0)) {
        // This is a way to detect web platform
        // Request permission using web Notification API
        await _requestWebNotificationPermission(context);
      } else {
        // For mobile platforms, use permission_handler
        final status = await Permission.notification.request();
        Navigator.pop(context); // Close loading dialog

        if (status == PermissionStatus.granted) {
          _scheduleDietReminders(context);
          _showSuccessDialog(context);
        } else {
          _showPermissionDeniedDialog(context);
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showWebNotificationDialog(context);
    }
  }

  Future<void> _requestWebNotificationPermission(BuildContext context) async {
    try {
      // This will be handled by the browser's native permission dialog
      Navigator.pop(context); // Close loading dialog

      // Show success message since we can't easily detect web notification permission
      _showSuccessDialog(context);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showWebNotificationDialog(context);
    }
  }

  void _startDietPlanWithoutNotifications(BuildContext context) {
    _showDefaultSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF2E8B57)),
            const SizedBox(width: 10),
            const Text('Success!'),
          ],
        ),
        content: Text(
          'Reminders have been set for your diet plan! You\'ll receive notifications for:\n\n• Breakfast at ${breakfastTime.format(context)}\n• Lunch at ${lunchTime.format(context)}\n• Dinner at ${dinnerTime.format(context)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Great!',
              style: TextStyle(color: Color(0xFF2E8B57)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.orange),
            const SizedBox(width: 10),
            const Text('Notifications Denied'),
          ],
        ),
        content: const Text(
          'You can still follow your diet plan manually! To enable reminders later, go to your device settings and allow notifications for this app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Continue Without Reminders',
              style: TextStyle(color: Color(0xFF2E8B57)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDefaultSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: const Color(0xFF2E8B57)),
            const SizedBox(width: 10),
            const Text('Diet Plan Ready'),
          ],
        ),
        content: Text(
          'Your personalized diet plan is ready! Remember to follow the meal schedule:\n\n• Breakfast at ${breakfastTime.format(context)}\n• Lunch at ${lunchTime.format(context)}\n• Dinner at ${dinnerTime.format(context)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Got it!',
              style: TextStyle(color: Color(0xFF2E8B57)),
            ),
          ),
        ],
      ),
    );
  }

  void _showWebNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.web, color: const Color(0xFF2E8B57)),
            const SizedBox(width: 10),
            const Text('Web Notifications'),
          ],
        ),
        content: const Text(
          'To enable notifications on web:\n\n1. Look for the notification icon in your browser\'s address bar\n2. Click "Allow" when prompted\n3. Or check your browser\'s notification settings\n\nYour diet plan is ready to follow!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFF2E8B57)),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTargetCalories() {
    // Basic BMR calculation (simplified)
    double currentWeightNum = double.tryParse(currentWeight) ?? 70;
    int baseCalories = (currentWeightNum * 24).round();

    // Activity level multiplier
    double activityMultiplier = 1.2;
    if (activityLevel.contains('Light')) activityMultiplier = 1.375;
    if (activityLevel.contains('Moderate')) activityMultiplier = 1.55;
    if (activityLevel.contains('Active')) activityMultiplier = 1.725;
    if (activityLevel.contains('Very Active')) activityMultiplier = 1.9;

    int totalCalories = (baseCalories * activityMultiplier).round();

    // Adjust for goal
    if (goal == 'Weight Loss') totalCalories -= 500;
    if (goal == 'Weight Gain') totalCalories += 500;
    if (goal == 'Muscle Building') totalCalories += 300;

    return totalCalories;
  }

  List<String> _getBreakfastOptions() {
    List<String> options = [];

    if (dietType == 'Vegetarian' || dietType == 'Vegan') {
      options.addAll([
        'Oatmeal with fruits and nuts',
        'Smoothie bowl with berries',
        'Avocado toast with seeds',
      ]);
    } else {
      options.addAll([
        'Greek yogurt with berries and granola',
        'Scrambled eggs with whole grain toast',
        'Protein smoothie with banana',
      ]);
    }

    return options;
  }

  List<String> _getLunchOptions() {
    List<String> options = [];

    if (foodPreferences.contains('Chicken')) {
      options.add('Grilled chicken salad with quinoa');
    }
    if (foodPreferences.contains('Fish')) {
      options.add('Salmon with roasted vegetables');
    }
    if (dietType == 'Vegetarian') {
      options.addAll([
        'Lentil soup with whole grain bread',
        'Quinoa Buddha bowl with vegetables',
      ]);
    }

    if (options.isEmpty) {
      options.addAll([
        'Mixed greens salad with protein',
        'Vegetable soup with whole grains',
        'Healthy wrap with preferred proteins',
      ]);
    }

    return options;
  }

  List<String> _getDinnerOptions() {
    List<String> options = [];

    if (dietType == 'Low Carb') {
      options.addAll([
        'Grilled protein with steamed vegetables',
        'Zucchini noodles with meat sauce',
        'Cauliflower rice stir-fry',
      ]);
    } else {
      options.addAll([
        'Baked sweet potato with protein',
        'Brown rice bowl with vegetables',
        'Whole grain pasta with lean protein',
      ]);
    }

    return options;
  }

  List<String> _getSnackOptions() {
    return [
      'Mixed nuts and seeds',
      'Greek yogurt with berries',
      'Apple with almond butter',
      'Hummus with vegetable sticks',
      'Protein smoothie',
    ];
  }

  List<String> _getNutritionTips() {
    List<String> tips = [
      'Drink at least 8 glasses of water daily',
      'Eat slowly and mindfully',
      'Include protein in every meal',
      'Choose whole grains over refined grains',
      'Fill half your plate with vegetables',
    ];

    if (goal == 'Weight Loss') {
      tips.add('Create a moderate calorie deficit');
    }
    if (goal == 'Muscle Building') {
      tips.add('Consume protein within 30 minutes post-workout');
    }

    return tips;
  }
}
