import 'package:flutter/material.dart';
import 'dart:math';
import '../Signin_Screen.dart';
import '../Login_Screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<String> _selectedAllergies = [];
  String _selectedGender = 'Male';
  String _selectedGoal = 'Maintain Weight';
  String? _profileImageUrl;

  final List<String> _allergies = [
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

  final List<String> _goals = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle',
    'General Health',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = SigninScreen.userData;
    _nameController.text = userData['name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _ageController.text = userData['age']?.toString() ?? '';
    _heightController.text = userData['height']?.toString() ?? '';
    _weightController.text = userData['weight']?.toString() ?? '';
    _selectedGender = userData['gender'] ?? 'Male';

    // Handle allergies as a comma-separated string
    final allergiesString = userData['allergies'] ?? '';
    if (allergiesString.isNotEmpty) {
      _selectedAllergies = allergiesString
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }

    _selectedGoal = userData['goal'] ?? 'Maintain Weight';
  }

  double _calculateBMI() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    if (height > 0 && weight > 0) {
      final heightInMeters = height / 100;
      return weight / (heightInMeters * heightInMeters);
    }
    return 0;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;
          final isDesktop = constraints.maxWidth >= 1024;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isDesktop)
                      _buildDesktopLayout()
                    else if (isTablet)
                      _buildTabletLayout()
                    else
                      _buildMobileLayout(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E8B57),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildProfileAvatar(size: 80),
                const SizedBox(height: 10),
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'User Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildProfileAvatar({double size = 50}) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: _profileImageUrl != null
              ? NetworkImage(_profileImageUrl!)
              : null,
          child: _profileImageUrl == null
              ? Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: size * 0.8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePicker,
            child: CircleAvatar(
              radius: size * 0.25,
              backgroundColor: const Color(0xFF2E8B57),
              child: Icon(
                Icons.camera_alt,
                size: size * 0.3,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 20),
        _buildBMICard(),
        const SizedBox(height: 20),
        _buildPersonalInfoSection(),
        const SizedBox(height: 20),
        _buildHealthInfoSection(),
        const SizedBox(height: 20),
        _buildAllergiesSection(),
        const SizedBox(height: 20),
        _buildGoalsSection(),
        const SizedBox(height: 30),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildProfileHeader()),
            const SizedBox(width: 20),
            Expanded(child: _buildBMICard()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildPersonalInfoSection()),
            const SizedBox(width: 20),
            Expanded(child: _buildHealthInfoSection()),
          ],
        ),
        const SizedBox(height: 20),
        _buildAllergiesSection(),
        const SizedBox(height: 20),
        _buildGoalsSection(),
        const SizedBox(height: 30),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildBMICard(),
              const SizedBox(height: 20),
              _buildPersonalInfoSection(),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildHealthInfoSection(),
              const SizedBox(height: 20),
              _buildAllergiesSection(),
              const SizedBox(height: 20),
              _buildGoalsSection(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
        children: [
          _buildProfileAvatar(size: 60),
          const SizedBox(height: 15),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : 'User Name',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 15),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Age', _ageController.text, Icons.cake),
        _buildStatItem('Gender', _selectedGender, Icons.people),
        _buildStatItem('Goal', _selectedGoal.split(' ')[0], Icons.flag),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E8B57), size: 24),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBMICard() {
    final bmi = _calculateBMI();
    final bmiCategory = _getBMICategory(bmi);
    final bmiColor = _getBMIColor(bmi);

    return Container(
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
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: bmiColor, size: 28),
              const SizedBox(width: 12),
              const Text(
                'BMI Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (bmi > 0) ...[
            Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: bmiColor,
              ),
            ),
            Text(
              bmiCategory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: bmiColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildBMIChart(bmi),
          ] else ...[
            const Text(
              'Enter height & weight\nto calculate BMI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBMIChart(double bmi) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
          stops: [0.18, 0.25, 0.30, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: _getBMIPosition(bmi),
            child: Container(
              width: 4,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getBMIPosition(double bmi) {
    // Scale BMI to position on chart (0-100%)
    double position = 0.0;
    if (bmi <= 18.5) {
      position = (bmi / 18.5) * 0.18;
    } else if (bmi <= 25) {
      position = 0.18 + ((bmi - 18.5) / (25 - 18.5)) * 0.07;
    } else if (bmi <= 30) {
      position = 0.25 + ((bmi - 25) / (30 - 25)) * 0.05;
    } else {
      position = 0.30 + min((bmi - 30) / 20, 0.7);
    }
    return position * 200; // Convert to pixels (assuming 200px width)
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            enabled: false,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildGenderSelector(),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Icon(Icons.people, color: Color(0xFF2E8B57)),
                SizedBox(width: 12),
                Text(
                  'Gender',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: _selectedGender,
                  activeColor: const Color(0xFF2E8B57),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection() {
    return _buildSection(
      title: 'Health Information',
      icon: Icons.health_and_safety,
      child: Column(
        children: [
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSection(
      title: 'Allergies & Dietary Restrictions',
      icon: Icons.warning,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allergies.map((allergy) {
          final isSelected = _selectedAllergies.contains(allergy);
          return FilterChip(
            label: Text(allergy),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedAllergies.add(allergy);
                } else {
                  _selectedAllergies.remove(allergy);
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
    );
  }

  Widget _buildGoalsSection() {
    return _buildSection(
      title: 'Health Goals',
      icon: Icons.flag,
      child: Column(
        children: _goals.map((goal) {
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
        }).toList(),
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
                  fontSize: 18,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: (_) => setState(() {}), // Trigger BMI recalculation
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Color(0xFF2E8B57), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveProfile,
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
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Save Profile',
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

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    // TODO: Implement camera functionality
                    Navigator.pop(context);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    // TODO: Implement gallery functionality
                    Navigator.pop(context);
                  },
                ),
                _buildImageOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () {
                    setState(() {
                      _profileImageUrl = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2E8B57).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF2E8B57)),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _saveProfile() {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }

    if (_ageController.text.trim().isNotEmpty) {
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 1 || age > 150) {
        _showSnackBar('Please enter a valid age (1-150)', isError: true);
        return;
      }
    }

    if (_heightController.text.trim().isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      if (height == null || height < 30 || height > 300) {
        _showSnackBar('Please enter a valid height (30-300 cm)', isError: true);
        return;
      }
    }

    if (_weightController.text.trim().isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight == null || weight < 10 || weight > 500) {
        _showSnackBar('Please enter a valid weight (10-500 kg)', isError: true);
        return;
      }
    }

    // Save data
    final userData = SigninScreen.userData;
    userData['name'] = _nameController.text.trim();
    userData['age'] = _ageController.text.trim();
    userData['height'] = _heightController.text.trim();
    userData['weight'] = _weightController.text.trim();
    userData['gender'] = _selectedGender;
    userData['allergies'] = _selectedAllergies.join(',');
    userData['goal'] = _selectedGoal;

    _showSnackBar('Profile updated successfully!');
    Navigator.pop(context);
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFF2E8B57)),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
