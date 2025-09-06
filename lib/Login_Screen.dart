import 'package:flutter/material.dart';
import 'Signin_Screen.dart';
import 'Dashboard_Screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  void _loadDemoUserData() {
    // Populate SigninScreen.userData with demo user data
    SigninScreen.userData = {
      'user_name': 'Demo User',
      'user_pet_name': 'Buddy',
      'user_email': 'test@gmail.com',
      'user_password': '123',
      'user_age': '25',
      'user_height': '175',
      'user_weight': '70',
      'user_gender': 'Male',
      'user_allergic': 'Peanuts, Shellfish',
      'user_disease': 'None',
      'user_description':
          'Health-conscious individual looking to maintain a balanced diet',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ElevatedButton(
              onPressed: () {
                // Validate login credentials
                String storedEmail = SigninScreen.userData['user_email'] ?? '';
                String storedPassword =
                    SigninScreen.userData['user_password'] ?? '';

                // Demo user credentials
                const String demoEmail = 'test@gmail.com';
                const String demoPassword = '123';

                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter email and password'),
                    ),
                  );
                } else if ((emailController.text == storedEmail &&
                        passwordController.text == storedPassword) ||
                    (emailController.text == demoEmail &&
                        passwordController.text == demoPassword)) {
                  // If demo user, populate with demo data
                  if (emailController.text == demoEmail) {
                    _loadDemoUserData();
                  }

                  // Login successful
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                } else {
                  // Invalid credentials
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid email or password')),
                  );
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SigninScreen()),
                    );
                  },
                  child: const Text('Sign in'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Demo User Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Demo User Credentials',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: test@gmail.com',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Password: 123',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          emailController.text = 'test@gmail.com';
                          passwordController.text = '123';
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Fill Demo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
