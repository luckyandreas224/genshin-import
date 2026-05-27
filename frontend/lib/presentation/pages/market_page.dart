import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/primogem_chip.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/item_card.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _items = []; // TODO
  bool _isLoading = false;

  final String baseUrl = ''; // cmd ipconfig -> IPv4 Address

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    // TODO
    try {
      final url = Uri.parse('$baseUrl/api/items');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final List<dynamic> fetchedData = decodedBody['data'] ?? decodedBody;
        setState(() {
          _items = fetchedData;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        const PrimogemChip(balance: 6767), // TODO
      ],
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchCtrl,
      onChanged: (value) {
        // TODO
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    // TODO
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.53,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];

        final String imagePath = item['image'] ?? '';
        final String fullImageUrl = baseUrl + imagePath;

        final String rawPrice = item['price']?.toString() ?? '0';
        final int displayPrice = double.tryParse(rawPrice)?.toInt() ?? 0;

        return ItemCard(
          imageUrl: fullImageUrl,
          title: item['name'] ?? 'Unknown Item',
          price: displayPrice,
          stock: item['stock'] ?? 0,
          onTap: () {
            // TODO
            debugPrint('Ditekan: ${item['name']}');
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
