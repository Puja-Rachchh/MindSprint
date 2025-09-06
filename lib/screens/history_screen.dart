import 'package:flutter/material.dart';
import 'product_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  // Sample history data - in a real app this would come from local storage
  final List<HistoryItem> _allHistoryItems = [
    HistoryItem(
      id: '1',
      name: 'Coca Cola Classic',
      brand: 'Coca Cola Company',
      barcode: '049000028391',
      calories: 140,
      scanDate: DateTime.now().subtract(const Duration(hours: 2)),
      isHealthy: false,
      isFavorite: true,
      category: 'Beverages',
    ),
    HistoryItem(
      id: '2',
      name: 'Greek Yogurt Plain',
      brand: 'Chobani',
      barcode: '894700010120',
      calories: 100,
      scanDate: DateTime.now().subtract(const Duration(hours: 5)),
      isHealthy: true,
      isFavorite: false,
      category: 'Dairy',
    ),
    HistoryItem(
      id: '3',
      name: 'Whole Wheat Bread',
      brand: 'Dave\'s Killer Bread',
      barcode: '013562000432',
      calories: 110,
      scanDate: DateTime.now().subtract(const Duration(days: 1)),
      isHealthy: true,
      isFavorite: true,
      category: 'Bakery',
    ),
    HistoryItem(
      id: '4',
      name: 'Potato Chips BBQ',
      brand: 'Lay\'s',
      barcode: '028400642736',
      calories: 160,
      scanDate: DateTime.now().subtract(const Duration(days: 2)),
      isHealthy: false,
      isFavorite: false,
      category: 'Snacks',
    ),
    HistoryItem(
      id: '5',
      name: 'Almond Milk Unsweetened',
      brand: 'Silk',
      barcode: '025293002906',
      calories: 40,
      scanDate: DateTime.now().subtract(const Duration(days: 3)),
      isHealthy: true,
      isFavorite: false,
      category: 'Beverages',
    ),
  ];

  List<HistoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allHistoryItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showClearHistoryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onChanged: (value) => _filterItems(),
            ),
          ),
          const SizedBox(height: 15),

          // Filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Favorites'),
                _buildFilterChip('Healthy'),
                _buildFilterChip('Unhealthy'),
                _buildFilterChip('Today'),
                _buildFilterChip('This Week'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
            _filterItems();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2E8B57).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2E8B57),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2E8B57) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(_filteredItems[index]);
      },
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  productName: item.name,
                  barcode: item.barcode,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Product icon and health indicator
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: item.isHealthy
                        ? const Color(0xFF38B2AC).withOpacity(0.1)
                        : const Color(0xFFE53E3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.isHealthy ? Icons.check_circle : Icons.warning,
                    color: item.isHealthy
                        ? const Color(0xFF38B2AC)
                        : const Color(0xFFE53E3E),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              item.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: item.isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(item.id),
                          ),
                        ],
                      ),
                      Text(
                        item.brand,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.calories} cal',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E8B57),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatDate(item.scanDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'No scan history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start scanning products to see your history here',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _filterItems() {
    setState(() {
      String query = _searchController.text.toLowerCase();

      _filteredItems = _allHistoryItems.where((item) {
        // Search filter
        bool matchesSearch =
            query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.brand.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);

        if (!matchesSearch) return false;

        // Category filter
        switch (_selectedFilter) {
          case 'Favorites':
            return item.isFavorite;
          case 'Healthy':
            return item.isHealthy;
          case 'Unhealthy':
            return !item.isHealthy;
          case 'Today':
            return _isToday(item.scanDate);
          case 'This Week':
            return _isThisWeek(item.scanDate);
          default:
            return true;
        }
      }).toList();

      // Sort by date (newest first)
      _filteredItems.sort((a, b) => b.scanDate.compareTo(a.scanDate));
    });
  }

  void _toggleFavorite(String itemId) {
    setState(() {
      final item = _allHistoryItems.firstWhere((item) => item.id == itemId);
      item.isFavorite = !item.isFavorite;
      _filterItems();
    });
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to clear all scan history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _allHistoryItems.clear();
                  _filteredItems.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully'),
                    backgroundColor: Color(0xFF38B2AC),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class HistoryItem {
  final String id;
  final String name;
  final String brand;
  final String barcode;
  final int calories;
  final DateTime scanDate;
  final bool isHealthy;
  bool isFavorite;
  final String category;

  HistoryItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.calories,
    required this.scanDate,
    required this.isHealthy,
    required this.isFavorite,
    required this.category,
  });
}
