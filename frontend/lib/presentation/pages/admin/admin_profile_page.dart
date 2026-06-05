import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stat_card.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => AdminProfilePageState();
}

class AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = false;
  String _token = '';
  String _username = '';
  String _email = '';
  int _totalItems = 0;

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> refresh() => _fetchData();

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? '';
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_token.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final userUrl = Uri.parse('$baseUrl/api/users/me');
      final userResponse = await http.get(
        userUrl,
        headers: {'Authorization': 'Bearer $_token'},
      );

      final itemsUrl = Uri.parse('$baseUrl/api/items');
      final itemsResponse = await http.get(itemsUrl);

      if (userResponse.statusCode == 200) {
        final userBody = jsonDecode(userResponse.body);
        final data = userBody['data'];
        setState(() {
          _username = data['username'] ?? '';
          _email = data['email'] ?? '';
        });
      }

      if (itemsResponse.statusCode == 200) {
        final itemsBody = jsonDecode(itemsResponse.body);
        final List<dynamic> items = itemsBody['data'] ?? [];
        setState(() => _totalItems = items.length);
      }
    } catch (e) {
      debugPrint('Error fetching admin profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading ? _buildLoadingState() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildHeader(),

        const SizedBox(height: 48),
        _buildProfileCard(),

        const SizedBox(height: 24),

        StatCard(
          title: 'Total Items in Store',
          value: '$_totalItems',
        ),

        const SizedBox(height: 24),

        CustomButton(
          label: 'Sign Out',
          isOutlined: true,
          color: AppColors.error,
          onPressed: _signOut,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Admin's Profile", style: AppTextStyles.heading),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryDark, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _username,
            style: GoogleFonts.ebGaramond(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
