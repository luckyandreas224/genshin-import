import 'dart:convert';
import 'package:genshin_import_fe/presentation/pages/item_detail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/primogem_chip.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = false;
  int _currency = 0;
  String _token = '';

  final String baseUrl = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? '';
    await Future.wait([_fetchItems(), _fetchCurrentUser()]);
  }

  Future<void> _fetchCurrentUser() async {
    if (_token.isEmpty) return;
    try {
      final url = Uri.parse('$baseUrl/api/users/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final String rawCurrency = body['data']['currency']?.toString() ?? '0';
        final int currency = double.tryParse(rawCurrency)?.toInt() ?? 0;
        setState(() => _currency = currency);
      } else {
        debugPrint('Failed to fetch user. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/api/items');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final List<dynamic> fetchedData = decodedBody['data'] ?? decodedBody;
        setState(() {
          _items = fetchedData;
          _filteredItems = fetchedData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint('Failed to fetch items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Network error: $e');
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      _filteredItems = query.isEmpty
          ? _items
          : _items.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              return name.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Traveler's Market", style: AppTextStyles.heading),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: 'Ready to buy some stuff, ',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: 'Traveler',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: '?',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        PrimogemChip(balance: _currency),
      ],
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchCtrl,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Text(
          'No items match.',
          style: GoogleFonts.ebGaramond(
            fontStyle: FontStyle.italic,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 128),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.53,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];

        final String imagePath = item['image'] ?? '';
        final String fullImageUrl = baseUrl + imagePath;

        final String rawPrice = item['price']?.toString() ?? '0';
        final int displayPrice = double.tryParse(rawPrice)?.toInt() ?? 0;

        final int itemId = (item['id'] as num?)?.toInt() ?? 0;

        return ItemCard(
          imageUrl: fullImageUrl,
          title: item['name'] ?? 'Unknown',
          price: displayPrice,
          stock: item['stock'] ?? 0,
          onTap: () async {
            final purchased = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailPage(
                  itemId: itemId,
                  token: _token, 
                  imageUrl: fullImageUrl,
                  title: item['name'] ?? 'Unknown',
                  category: item['type'] ?? 'Unknown',
                  description: item['description'] ?? 'No description available for this item.',
                  price: displayPrice,
                  stock: item['stock'] ?? 0,
                ),
              ),
            );
            if (purchased == true) {
              _fetchItems(); 
              _fetchCurrentUser();
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Nothing to see here yet.\nComeback later, Traveler!',
        textAlign: TextAlign.center,
        style: GoogleFonts.ebGaramond(
          fontStyle: FontStyle.italic,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}