import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A5ACD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildPersonalInfoSection(),
            const SizedBox(height: 30),
            _buildHealthInfoSection(),
            const SizedBox(height: 30),
            _buildAllergiesSection(),
            const SizedBox(height: 30),
            _buildGoalsSection(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
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
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF6A5ACD),
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _emailController.text,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
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
          _buildGenderText(),
        ],
      ),
    );
  }

  Widget _buildGenderText() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Color(0xFF6A5ACD)),
          const SizedBox(width: 12),
          Text(
            'Gender: _selectedGender',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection() {
    return _buildSection(
      title: 'Health Information',
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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
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
            selectedColor: const Color(0xFF6A5ACD).withOpacity(0.2),
            checkmarkColor: const Color(0xFF6A5ACD),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return _buildSection(
      title: 'Health Goals',
      child: Column(
        children: _goals.map((goal) {
          return RadioListTile<String>(
            title: Text(goal),
            value: goal,
            groupValue: _selectedGoal,
            activeColor: const Color(0xFF6A5ACD),
            onChanged: (value) {
              setState(() {
                _selectedGoal = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6A5ACD)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6A5ACD), width: 2),
        ),
        filled: true,
      ),
    );
  }

  // ...existing code...

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A5ACD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Save Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveProfile() {
    final userData = SigninScreen.userData;
    userData['name'] = _nameController.text;
    userData['age'] = _ageController.text;
    userData['height'] = _heightController.text;
    userData['weight'] = _weightController.text;
    userData['gender'] = _selectedGender;
    userData['allergies'] = _selectedAllergies.join(',');
    userData['goal'] = _selectedGoal;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Color(0xFF38B2AC),
      ),
    );

    Navigator.pop(context);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Logout'),
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
                backgroundColor: const Color(0xFF6A5ACD),
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
