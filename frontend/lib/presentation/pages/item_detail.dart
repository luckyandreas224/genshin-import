import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_toast.dart'; 

class ItemDetailPage extends StatefulWidget {
  final int itemId;       
  final String token;     
  final String imageUrl;
  final String title;
  final String category;
  final String description;
  final int price;
  final int stock;

  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.token,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  int _quantity = 1;
  bool _isBuying = false;

  final String baseUrl = '';

  void _incrementQuantity() {
    if (_quantity < widget.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _buyItem() async {
    setState(() => _isBuying = true);

    try {
      final url = Uri.parse('$baseUrl/api/items/${widget.itemId}/buy');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': _quantity}),
      );

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = body['data'];
        final int remaining = data['remaining_currency'] ?? 0;
        final int totalOwned = data['total_owned'] ?? 0;

        CustomToast.showTopToast(
          context,
          'Purchased $_quantity x ${widget.title}!\nOwned: $totalOwned | Remaining: $remaining',
          AppColors.success,
        );

        Navigator.pop(context, true);
      } else {
        final message = body['message'] ?? 'Purchase failed';
        
        CustomToast.showTopToast(context, message, AppColors.error);
      }
    } catch (e) {
      if (!mounted) return;
      
      CustomToast.showTopToast(context, 'Network error. Please try again.', AppColors.error);
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = widget.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.border,
                child: const Icon(Icons.broken_image, size: 50, color: AppColors.textSecondary),
              ),
            ),
          ),

          Positioned(
            top: 75,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container( 
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
              ),
            ),
          ),

          Positioned(
            top: 290,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.ebGaramond(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 34),
                    decoration: const BoxDecoration(color: AppColors.background),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/images/primogem.png', width: 24, height: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Price: ${widget.price}',
                                        style: GoogleFonts.ebGaramond(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/images/stock.png', width: 24, height: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Stock: ${widget.stock}',
                                        style: GoogleFonts.ebGaramond(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _isBuying ? null : _decrementQuantity,
                                    behavior: HitTestBehavior.opaque,
                                    child: Icon(
                                      Icons.remove,
                                      size: 24,
                                      color: (_quantity > 1 && !_isBuying)
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '$_quantity',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.ebGaramond(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _isBuying ? null : _incrementQuantity,
                                    behavior: HitTestBehavior.opaque,
                                    child: Icon(
                                      Icons.add,
                                      size: 24,
                                      color: (_quantity < widget.stock && !_isBuying)
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        _isBuying
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: CircularProgressIndicator(),
                              )
                            : CustomButton(
                                label: 'Buy - $totalPrice',
                                onPressed: _buyItem,
                              ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}