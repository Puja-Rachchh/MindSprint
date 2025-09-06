import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I scan a barcode?',
      answer:
          'Simply tap the "Scan Barcode" button on the home screen and point your camera at the product barcode. Make sure the barcode is well-lit and clearly visible.',
    ),
    FAQItem(
      question: 'What if a product is not found?',
      answer:
          'If a product is not in our database, you can try searching manually or contact support to add the product.',
    ),
    FAQItem(
      question: 'How do I set up allergen warnings?',
      answer:
          'Go to your profile settings and select your allergies and dietary restrictions. The app will automatically warn you about products containing these allergens.',
    ),
    FAQItem(
      question: 'Can I use the app offline?',
      answer:
          'The barcode scanning feature requires an internet connection to fetch product information. However, your scan history is stored locally.',
    ),
    FAQItem(
      question: 'How accurate is the nutritional information?',
      answer:
          'We source our data from verified databases including OpenFoodFacts and manufacturer information. However, always check the product label for the most accurate information.',
    ),
    FAQItem(
      question: 'How do I export my scan history?',
      answer:
          'Go to Settings > Privacy & Data > Export Data to download your complete scan history.',
    ),
    FAQItem(
      question: 'Is my data secure?',
      answer:
          'Yes, your data is stored locally on your device and only basic anonymized usage statistics are shared to improve the app.',
    ),
    FAQItem(
      question: 'How do I delete my account?',
      answer:
          'Contact our support team through the feedback option in Settings to request account deletion.',
    ),
  ];

  final List<FeatureGuide> _guides = [
    FeatureGuide(
      title: 'Getting Started',
      description: 'Learn the basics of using MindSprint',
      icon: Icons.play_circle,
      steps: [
        'Create your account and set up your profile',
        'Add your allergies and dietary preferences',
        'Start scanning products by tapping the scan button',
        'Review nutritional information and allergen warnings',
        'Check your history to track scanned products',
      ],
    ),
    FeatureGuide(
      title: 'Barcode Scanning',
      description: 'How to effectively scan product barcodes',
      icon: Icons.qr_code_scanner,
      steps: [
        'Ensure good lighting conditions',
        'Hold your phone steady and point at the barcode',
        'Wait for the scanning frame to turn green',
        'Review the product information displayed',
        'Check for any allergen warnings',
      ],
    ),
    FeatureGuide(
      title: 'Managing Allergies',
      description: 'Set up and manage your allergen preferences',
      icon: Icons.warning,
      steps: [
        'Go to Profile > Edit Profile',
        'Scroll to "Allergies & Dietary Restrictions"',
        'Select all relevant allergies',
        'Save your profile changes',
        'Receive automatic warnings when scanning',
      ],
    ),
    FeatureGuide(
      title: 'Using History',
      description: 'Track and manage your scanned products',
      icon: Icons.history,
      steps: [
        'Access history from the home screen',
        'Use filters to find specific products',
        'Mark products as favorites',
        'Compare nutritional information',
        'Export data when needed',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6A5ACD),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Guides'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_FAQTab(), _GuidesTab(), _ContactTab()],
        ),
      ),
    );
  }
}

class _FAQTab extends StatefulWidget {
  const _FAQTab();

  @override
  State<_FAQTab> createState() => _FAQTabState();
}

class _FAQTabState extends State<_FAQTab> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I scan a barcode?',
      answer:
          'Simply tap the "Scan Barcode" button on the home screen and point your camera at the product barcode. Make sure the barcode is well-lit and clearly visible.',
    ),
    FAQItem(
      question: 'What if a product is not found?',
      answer:
          'If a product is not in our database, you can try searching manually or contact support to add the product.',
    ),
    FAQItem(
      question: 'How do I set up allergen warnings?',
      answer:
          'Go to your profile settings and select your allergies and dietary restrictions. The app will automatically warn you about products containing these allergens.',
    ),
    FAQItem(
      question: 'Can I use the app offline?',
      answer:
          'The barcode scanning feature requires an internet connection to fetch product information. However, your scan history is stored locally.',
    ),
    FAQItem(
      question: 'How accurate is the nutritional information?',
      answer:
          'We source our data from verified databases including OpenFoodFacts and manufacturer information. However, always check the product label for the most accurate information.',
    ),
    FAQItem(
      question: 'How do I export my scan history?',
      answer:
          'Go to Settings > Privacy & Data > Export Data to download your complete scan history.',
    ),
    FAQItem(
      question: 'Is my data secure?',
      answer:
          'Yes, your data is stored locally on your device and only basic anonymized usage statistics are shared to improve the app.',
    ),
    FAQItem(
      question: 'How do I delete my account?',
      answer:
          'Contact our support team through the feedback option in Settings to request account deletion.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _faqItems.length,
      itemBuilder: (context, index) {
        return _buildFAQCard(_faqItems[index]);
      },
    );
  }

  Widget _buildFAQCard(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: ExpansionTile(
        title: Text(
          item.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidesTab extends StatelessWidget {
  const _GuidesTab();

  final List<FeatureGuide> _guides = const [
    FeatureGuide(
      title: 'Getting Started',
      description: 'Learn the basics of using MindSprint',
      icon: Icons.play_circle,
      steps: [
        'Create your account and set up your profile',
        'Add your allergies and dietary preferences',
        'Start scanning products by tapping the scan button',
        'Review nutritional information and allergen warnings',
        'Check your history to track scanned products',
      ],
    ),
    FeatureGuide(
      title: 'Barcode Scanning',
      description: 'How to effectively scan product barcodes',
      icon: Icons.qr_code_scanner,
      steps: [
        'Ensure good lighting conditions',
        'Hold your phone steady and point at the barcode',
        'Wait for the scanning frame to turn green',
        'Review the product information displayed',
        'Check for any allergen warnings',
      ],
    ),
    FeatureGuide(
      title: 'Managing Allergies',
      description: 'Set up and manage your allergen preferences',
      icon: Icons.warning,
      steps: [
        'Go to Profile > Edit Profile',
        'Scroll to "Allergies & Dietary Restrictions"',
        'Select all relevant allergies',
        'Save your profile changes',
        'Receive automatic warnings when scanning',
      ],
    ),
    FeatureGuide(
      title: 'Using History',
      description: 'Track and manage your scanned products',
      icon: Icons.history,
      steps: [
        'Access history from the home screen',
        'Use filters to find specific products',
        'Mark products as favorites',
        'Compare nutritional information',
        'Export data when needed',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _guides.length,
      itemBuilder: (context, index) {
        return _buildGuideCard(_guides[index]);
      },
    );
  }

  Widget _buildGuideCard(FeatureGuide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A5ACD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    guide.icon,
                    color: const Color(0xFF6A5ACD),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        guide.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...guide.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A5ACD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _ContactTab extends StatelessWidget {
  const _ContactTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We\'re here to help! Choose the best way to reach us.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          _buildContactCard(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'Get help via email',
            description: 'support@mindsprint.com',
            onTap: () {
              // In a real app, this would open the email client
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email client...')),
              );
            },
          ),
          const SizedBox(height: 15),

          _buildContactCard(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            description: 'Available 9 AM - 6 PM EST',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat coming soon!')),
              );
            },
          ),
          const SizedBox(height: 15),

          _buildContactCard(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Found something wrong?',
            description: 'Help us fix it',
            onTap: () {
              _showBugReportDialog(context);
            },
          ),
          const SizedBox(height: 15),

          _buildContactCard(
            icon: Icons.lightbulb,
            title: 'Suggest a Feature',
            subtitle: 'Have an idea?',
            description: 'We\'d love to hear it',
            onTap: () {
              _showFeatureRequestDialog(context);
            },
          ),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6A5ACD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF6A5ACD), size: 40),
                const SizedBox(height: 15),
                const Text(
                  'Support Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Monday - Friday: 9:00 AM - 6:00 PM EST\nWeekends: 10:00 AM - 4:00 PM EST',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
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
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A5ACD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Report a Bug'),
          content: const Text(
            'To report a bug, please send us an email at support@mindsprint.com with:\n\n• Description of the issue\n• Steps to reproduce\n• Your device information\n• Screenshots (if applicable)',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
              ),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Suggest a Feature'),
          content: const Text(
            'We love hearing your ideas! Send us your feature suggestions at support@mindsprint.com.\n\nPlease include:\n• Detailed description\n• Why it would be helpful\n• Any mockups or examples',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
              ),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class FeatureGuide {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  const FeatureGuide({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}
