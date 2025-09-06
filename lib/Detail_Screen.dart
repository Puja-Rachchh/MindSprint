import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'Login_Screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController allergicController = TextEditingController();
  final TextEditingController diseaseController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _saveDetailData() async {
    // Add additional details to the existing user data
    SigninScreen.userData['user_height'] = heightController.text;
    SigninScreen.userData['user_weight'] = weightController.text;
    SigninScreen.userData['user_allergic'] = allergicController.text;
    SigninScreen.userData['user_disease'] = diseaseController.text;
    SigninScreen.userData['user_description'] = descriptionController.text;
    SigninScreen.userData['user_gender'] = _selectedGender ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Fetch data from local storage
    String userName = SigninScreen.userData['user_name'] ?? 'Unknown';
    String userAge = SigninScreen.userData['user_age'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('Additional Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display fetched data
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: $userName'),
                      Text('Age: $userAge years'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Additional details form
              // ...existing code...
              // ...existing code...
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: allergicController,
                decoration: const InputDecoration(
                  labelText: 'Allergic to',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: diseaseController,
                decoration: const InputDecoration(
                  labelText: 'Any disease',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Validate required fields
                  if (heightController.text.isEmpty ||
                      weightController.text.isEmpty ||
                      allergicController.text.isEmpty ||
                      diseaseController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  // Save additional details
                  _saveDetailData()
                      .then((_) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Details saved successfully!'),
                          ),
                        );

                        // Navigate to login screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${error.toString()}')),
                        );
                      });
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
