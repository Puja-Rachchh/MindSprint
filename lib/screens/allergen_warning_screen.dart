import 'package:flutter/material.dart';

class AllergenWarningScreen extends StatelessWidget {
  final String productName;
  final List<String> allergens;
  final String? photoUrl;

  const AllergenWarningScreen({
    super.key,
    required this.productName,
    required this.allergens,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAllergens =
        allergens.isNotEmpty && !allergens.contains('None detected');

    return Scaffold(
      backgroundColor: hasAllergens
          ? const Color(0xFFFFF5F5)
          : const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Allergen Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: hasAllergens
            ? const Color(0xFFE53E3E)
            : const Color(0xFF38B2AC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningHeader(hasAllergens),
            const SizedBox(height: 30),
            _buildProductInfo(),
            const SizedBox(height: 30),
            _buildAllergenDetails(hasAllergens),
            const SizedBox(height: 30),
            _buildRecommendations(hasAllergens),
            const SizedBox(height: 30),
            _buildActionButtons(context, hasAllergens),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningHeader(bool hasAllergens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: hasAllergens
            ? const Color(0xFFE53E3E).withOpacity(0.1)
            : const Color(0xFF38B2AC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAllergens
              ? const Color(0xFFE53E3E).withOpacity(0.3)
              : const Color(0xFF38B2AC).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: hasAllergens
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF38B2AC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAllergens ? Icons.warning : Icons.check_circle,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasAllergens ? '⚠️ ALLERGEN WARNING' : '✅ SAFE TO CONSUME',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: hasAllergens
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF38B2AC),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            hasAllergens
                ? 'This product contains allergens that match your profile'
                : 'No allergens detected for your dietary restrictions',
            style: TextStyle(
              fontSize: 16,
              color: hasAllergens
                  ? const Color(0xFFE53E3E).withOpacity(0.8)
                  : const Color(0xFF38B2AC).withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Product Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: photoUrl!.startsWith('assets/')
                            ? Image.asset(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, color: Colors.grey);
                                },
                              )
                            : Image.network(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, color: Colors.grey);
                                },
                              ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Scanned just now',
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
        ],
      ),
    );
  }

  Widget _buildAllergenDetails(bool hasAllergens) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Allergen Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),

          if (hasAllergens) ...[
            const Text(
              'Detected Allergens:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            ...allergens
                .map((allergen) => _buildAllergenItem(allergen, true))
                .toList(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF38B2AC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF38B2AC)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No allergens found that match your profile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF38B2AC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Text(
            'Your Profile Allergens:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 10),
          // Mock user allergens - in real app, get from user profile
          _buildAllergenItem('Peanuts', false),
          _buildAllergenItem('Dairy', false),
          _buildAllergenItem('Gluten', false),
        ],
      ),
    );
  }

  Widget _buildAllergenItem(String allergen, bool isDetected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isDetected ? Icons.warning : Icons.info_outline,
            color: isDetected ? const Color(0xFFE53E3E) : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            allergen,
            style: TextStyle(
              fontSize: 14,
              color: isDetected
                  ? const Color(0xFFE53E3E)
                  : Colors.grey.shade700,
              fontWeight: isDetected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(bool hasAllergens) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            hasAllergens ? 'Recommendations' : 'Good to Know',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),

          if (hasAllergens) ...[
            _buildRecommendationItem(
              Icons.block,
              'Avoid this product',
              'Contains allergens matching your profile',
              const Color(0xFFE53E3E),
            ),
            _buildRecommendationItem(
              Icons.search,
              'Check alternatives',
              'Look for similar products without these allergens',
              const Color(0xFF805AD5),
            ),
            _buildRecommendationItem(
              Icons.medical_services,
              'Consult healthcare provider',
              'If unsure about severity of your allergies',
              const Color(0xFF3182CE),
            ),
          ] else ...[
            _buildRecommendationItem(
              Icons.check_circle,
              'Safe to consume',
              'No detected allergens match your profile',
              const Color(0xFF38B2AC),
            ),
            _buildRecommendationItem(
              Icons.visibility,
              'Always read labels',
              'Manufacturing processes can change',
              const Color(0xFF805AD5),
            ),
            _buildRecommendationItem(
              Icons.update,
              'Keep profile updated',
              'Update your allergen list if it changes',
              const Color(0xFF3182CE),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool hasAllergens) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasAllergens
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF38B2AC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              hasAllergens ? 'I Understand - Go Back' : 'Great - Go Back',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              _showShareDialog(context, hasAllergens);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: hasAllergens
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF38B2AC),
              side: BorderSide(
                color: hasAllergens
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF38B2AC),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Share This Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context, bool hasAllergens) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Share Report'),
          content: Text(
            hasAllergens
                ? 'Share this allergen warning with family or friends to help them stay safe.'
                : 'Share this safety confirmation with others.',
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
                  const SnackBar(content: Text('Report shared successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
              ),
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }
}