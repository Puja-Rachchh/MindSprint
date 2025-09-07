import 'package:flutter/material.dart';
import 'Login_Screen.dart';
import 'Detail_Screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  // Static map to store user data temporarily (in-memory storage)
  static Map<String, String> userData = {};

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? _selectedGender = null;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _saveUserData() async {
    // Store data in memory instead of SharedPreferences
    SigninScreen.userData['user_name'] = nameController.text;
    SigninScreen.userData['user_pet_name'] = petNameController.text;
    SigninScreen.userData['user_email'] = emailController.text;
    SigninScreen.userData['user_password'] = passwordController.text;
    SigninScreen.userData['user_age'] = ageController.text;
    SigninScreen.userData['user_gender'] = _selectedGender ?? '';
    SigninScreen.userData['gender'] = _selectedGender ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.white),
            SizedBox(width: 8),
            Text('Sign Up - NutriGo'),
          ],
        ),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF2E8B57)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E8B57), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: petNameController,
                decoration: const InputDecoration(
                  labelText: 'Nick Name',
                  prefixIcon: Icon(Icons.pets, color: Color(0xFF2E8B57)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E8B57), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: [
                  const DropdownMenuItem(value: 'Male', child: Text('Male')),
                  const DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                  const DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Validate all fields are filled
                  if (nameController.text.isEmpty ||
                      petNameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty ||
                      ageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  // Validate password match
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  // Store user data in local storage
                  _saveUserData()
                      .then((_) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account created successfully!'),
                          ),
                        );

                        // Navigate to detail screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(),
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
