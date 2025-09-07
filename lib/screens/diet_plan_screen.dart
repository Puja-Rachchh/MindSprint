import 'package:flutter/material.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  // Diet preferences
  final List<String> _foodPreferences = [
    'Vegetarian',
    'Vegan',
    'Non-Vegetarian',
    'Pescatarian',
    'Flexitarian',
    'Raw Food',
    'Mediterranean',
    'Keto',
    'Paleo',
    'Low-Carb',
  ];

  final List<String> _selectedFoodPreferences = [];

  // Health goals
  String _selectedGoal = 'Weight Loss';
  final List<String> _healthGoals = [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Heart Health',
    'Diabetes Management',
    'General Health',
    'Athletic Performance',
    'Digestive Health',
  ];

  // Activity level
  String _activityLevel = 'Moderate';
  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  // Budget preference
  String _budgetRange = 'Medium';
  final List<String> _budgetRanges = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 8),
            Text('Diet Plan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 30),
            _buildFoodPreferencesSection(),
            const SizedBox(height: 30),
            _buildHealthGoalSection(),
            const SizedBox(height: 30),
            _buildActivityLevelSection(),
            const SizedBox(height: 30),
            _buildBudgetSection(),
            const SizedBox(height: 40),
            _buildGeneratePlanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF38B2AC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.emoji_food_beverage, size: 50, color: Colors.white),
          SizedBox(height: 15),
          Text(
            'Personalized Diet Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Tell us about your preferences and goals to create a customized nutrition plan just for you!',
            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    return _buildSection(
      title: 'Food Preferences',
      icon: Icons.restaurant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your dietary preferences:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _foodPreferences.map((preference) {
              final isSelected = _selectedFoodPreferences.contains(preference);
              return FilterChip(
                label: Text(preference),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFoodPreferences.add(preference);
                    } else {
                      _selectedFoodPreferences.remove(preference);
                    }
                  });
                },
                selectedColor: const Color(0xFF2E8B57).withOpacity(0.2),
                checkmarkColor: const Color(0xFF2E8B57),
                backgroundColor: Colors.grey.shade50,
                elevation: isSelected ? 2 : 0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthGoalSection() {
    return _buildSection(
      title: 'Health Goals',
      icon: Icons.flag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your primary health goal?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          ..._healthGoals.map((goal) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _selectedGoal == goal
                    ? const Color(0xFF2E8B57).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGoal == goal
                      ? const Color(0xFF2E8B57)
                      : Colors.grey.shade300,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  goal,
                  style: TextStyle(
                    fontWeight: _selectedGoal == goal
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                value: goal,
                groupValue: _selectedGoal,
                activeColor: const Color(0xFF2E8B57),
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value!;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSection() {
    return _buildSection(
      title: 'Activity Level',
      icon: Icons.fitness_center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How active are you?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          ..._activityLevels.map((level) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _activityLevel == level
                    ? const Color(0xFF2E8B57).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _activityLevel == level
                      ? const Color(0xFF2E8B57)
                      : Colors.grey.shade300,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  level,
                  style: TextStyle(
                    fontWeight: _activityLevel == level
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(_getActivityDescription(level)),
                value: level,
                groupValue: _activityLevel,
                activeColor: const Color(0xFF2E8B57),
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return _buildSection(
      title: 'Budget Range',
      icon: Icons.attach_money,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your preferred budget range for meals?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          ..._budgetRanges.map((budget) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _budgetRange == budget
                    ? const Color(0xFF2E8B57).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _budgetRange == budget
                      ? const Color(0xFF2E8B57)
                      : Colors.grey.shade300,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  budget,
                  style: TextStyle(
                    fontWeight: _budgetRange == budget
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(_getBudgetDescription(budget)),
                value: budget,
                groupValue: _budgetRange,
                activeColor: const Color(0xFF2E8B57),
                onChanged: (value) {
                  setState(() {
                    _budgetRange = value!;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E8B57)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
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

  Widget _buildGeneratePlanButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _generateDietPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Generate My Diet Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'Sedentary':
        return 'Little to no exercise';
      case 'Light':
        return 'Light exercise 1-3 days/week';
      case 'Moderate':
        return 'Moderate exercise 3-5 days/week';
      case 'Active':
        return 'Hard exercise 6-7 days/week';
      case 'Very Active':
        return 'Very hard exercise, physical job';
      default:
        return '';
    }
  }

  String _getBudgetDescription(String budget) {
    switch (budget) {
      case 'Low':
        return 'Budget-friendly meals';
      case 'Medium':
        return 'Moderate spending on quality ingredients';
      case 'High':
        return 'Premium ingredients and dining options';
      default:
        return '';
    }
  }

  void _generateDietPlan() {
    if (_selectedFoodPreferences.isEmpty) {
      _showSnackBar(
        'Please select at least one food preference',
        isError: true,
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E8B57)),
        ),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Remove loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Plan Generated!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your personalized diet plan has been created based on:',
              ),
              const SizedBox(height: 10),
              Text('• Preferences: ${_selectedFoodPreferences.join(', ')}'),
              Text('• Goal: $_selectedGoal'),
              Text('• Activity: $_activityLevel'),
              Text('• Budget: $_budgetRange'),
              const SizedBox(height: 15),
              const Text(
                'Your plan includes meal recommendations, portion sizes, and shopping lists tailored to your preferences.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('View Plan'),
            ),
          ],
        ),
      );
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF38B2AC),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
