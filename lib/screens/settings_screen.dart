import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'help_screen.dart';
import '../Login_Screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A5ACD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSection(),
            const SizedBox(height: 30),
            _buildAppearanceSection(),
            const SizedBox(height: 30),
            _buildNotificationSection(),
            const SizedBox(height: 30),
            _buildPrivacySection(),
            const SizedBox(height: 30),
            _buildSupportSection(),
            const SizedBox(height: 30),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return _buildSection(
      title: 'User',
      items: [
        _buildSettingsItem(
          icon: Icons.person,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          },
          showTrailing: true,
        ),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'Privacy Settings',
          subtitle: 'Manage your privacy preferences',
          onTap: () {
            _showComingSoonDialog('Privacy Settings');
          },
          showTrailing: true,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Appearance',
      items: [
        _buildSwitchItem(
          icon: Icons.dark_mode,
          title: 'Dark Mode',
          subtitle: 'Switch to dark theme',
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
            _showComingSoonDialog('Dark Mode');
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications & Sound',
      items: [
        _buildSwitchItem(
          icon: Icons.notifications,
          title: 'Push Notifications',
          subtitle: 'Receive alerts and updates',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
        _buildSwitchItem(
          icon: Icons.volume_up,
          title: 'Sound Effects',
          subtitle: 'Play sounds for actions',
          value: _soundEffects,
          onChanged: (value) {
            setState(() {
              _soundEffects = value;
            });
          },
        ),
        _buildSwitchItem(
          icon: Icons.vibration,
          title: 'Haptic Feedback',
          subtitle: 'Vibrate on interactions',
          value: _hapticFeedback,
          onChanged: (value) {
            setState(() {
              _hapticFeedback = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy & Data',
      items: [
        _buildSettingsItem(
          icon: Icons.history,
          title: 'Clear Scan History',
          subtitle: 'Remove all saved scan data',
          onTap: () {
            _showClearDataDialog();
          },
          showTrailing: false,
        ),
        _buildSettingsItem(
          icon: Icons.download,
          title: 'Export Data',
          subtitle: 'Download your data',
          onTap: () {
            _showComingSoonDialog('Data Export');
          },
          showTrailing: true,
        ),
        _buildSettingsItem(
          icon: Icons.policy,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            _showComingSoonDialog('Privacy Policy');
          },
          showTrailing: true,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support',
      items: [
        _buildSettingsItem(
          icon: Icons.help,
          title: 'Help & FAQ',
          subtitle: 'Get help using the app',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          },
          showTrailing: true,
        ),
        _buildSettingsItem(
          icon: Icons.feedback,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          onTap: () {
            _showComingSoonDialog('Feedback');
          },
          showTrailing: true,
        ),
        _buildSettingsItem(
          icon: Icons.star_rate,
          title: 'Rate App',
          subtitle: 'Rate us on the app store',
          onTap: () {
            _showComingSoonDialog('Rate App');
          },
          showTrailing: true,
        ),
        _buildSettingsItem(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog();
          },
          showTrailing: true,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Account',
      items: [
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: () {
            _showLogoutDialog();
          },
          showTrailing: false,
          iconColor: const Color(0xFFE53E3E),
          titleColor: const Color(0xFFE53E3E),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Container(
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200, indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showTrailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF6A5ACD)).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF6A5ACD),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showTrailing)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6A5ACD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6A5ACD), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6A5ACD),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Coming Soon'),
          content: Text('$feature is coming in a future update!'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'MindSprint',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(
            Icons.qr_code_scanner,
            size: 50,
            color: Color(0xFF6A5ACD),
          ),
          children: const [
            Text('Scan Smart, Eat Healthy'),
            SizedBox(height: 10),
            Text(
              'MindSprint helps you make informed food choices by scanning barcodes and providing detailed nutritional information.',
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all your scan history and saved data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Color(0xFF38B2AC),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
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
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
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
                backgroundColor: const Color(0xFFE53E3E),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
