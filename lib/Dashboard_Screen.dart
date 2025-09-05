import 'package:flutter/material.dart';
import 'Signin_Screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildNutrifyPage();
      case 2:
        return _buildStatisticsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Padding(
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
                onPressed: () {
                  // TODO: Implement QR code scanning functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code Scanner clicked')),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
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
                  // TODO: Implement image upload functionality
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
