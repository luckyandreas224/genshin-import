import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_toast.dart';

class AdminItemsPage extends StatefulWidget {
  const AdminItemsPage({super.key});

  @override
  State<AdminItemsPage> createState() => _AdminItemsPageState();
}

class _AdminItemsPageState extends State<AdminItemsPage> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = false;
  String _token = '';

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

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
    await _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/api/items');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final List<dynamic> fetchedData = decodedBody['data'] ?? [];
        setState(() {
          _items = fetchedData;
          _filteredItems = fetchedData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint('Failed to fetch items. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Network error: $e');
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    final int itemId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
    final String itemName = item['name'] ?? 'Item';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Item',
          style: GoogleFonts.ebGaramond(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$itemName"? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final url = Uri.parse('$baseUrl/api/items/$itemId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomToast.showTopToast(
          context,
          '"$itemName" deleted successfully.',
          AppColors.success,
        );
        await _fetchItems();
      } else {
        final message = body['message'] ?? 'Delete failed';
        CustomToast.showTopToast(context, message, AppColors.error);
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.showTopToast(
        context,
        'Network error. Please try again.',
        AppColors.error,
      );
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

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemFormSheet(
        token: _token,
        baseUrl: baseUrl,
        onSuccess: () {
          _searchCtrl.clear();
          _onSearchChanged('');
          _fetchItems();
        },
      ),
    );
  }

  void _showEditItemSheet(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemFormSheet(
        token: _token,
        baseUrl: baseUrl,
        item: Map<String, dynamic>.from(item as Map),
        onSuccess: () {
          _searchCtrl.clear();
          _onSearchChanged('');
          _fetchItems();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 104),
        child: FloatingActionButton(
          onPressed: _showAddItemSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
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
              CustomSearchBar(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
              ),
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
              Text("Admin's Loadout", style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                '${_items.length} item${_items.length == 1 ? '' : 's'} in store',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 128),
      itemCount: _filteredItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _AdminItemTile(
          item: item,
          baseUrl: baseUrl,
          onEdit: () => _showEditItemSheet(item),
          onDelete: () => _deleteItem(item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No items yet.\nTap + to add your first item!',
            textAlign: TextAlign.center,
            style: GoogleFonts.ebGaramond(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemFormSheet extends StatefulWidget {
  final String token;
  final String baseUrl;
  final Map<String, dynamic>? item; // null = add mode
  final VoidCallback onSuccess;

  const _ItemFormSheet({
    required this.token,
    required this.baseUrl,
    this.item,
    required this.onSuccess,
  });

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _priceCtrl;
  late String _selectedType;
  XFile? _pickedImage;
  bool _isLoading = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?['name'] ?? '');
    _descCtrl = TextEditingController(text: item?['description'] ?? '');
    _stockCtrl = TextEditingController(
      text: item != null ? (int.tryParse(item['stock']?.toString() ?? '')?.toString() ?? '') : '',
    );
    _priceCtrl = TextEditingController(
      text: item != null ? (double.tryParse(item['price']?.toString() ?? '')?.toInt().toString() ?? '') : '',
    );
    final rawType = (item?['type'] ?? 'weapon').toString().toLowerCase();
    _selectedType = ['weapon', 'artifact'].contains(rawType) ? rawType : 'weapon';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _pickedImage = picked);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        CustomToast.showTopToast(
          context,
          'Failed to open gallery. If you just added the plugin, try restarting the app.',
          AppColors.error,
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Uri url;
      final String method;

      if (_isEdit) {
        final int itemId = int.tryParse(widget.item!['id']?.toString() ?? '') ?? 0;
        url = Uri.parse('${widget.baseUrl}/api/items/$itemId');
        method = 'PUT';
      } else {
        url = Uri.parse('${widget.baseUrl}/api/items');
        method = 'POST';
      }

      final request = http.MultipartRequest(method, url);
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['name'] = _nameCtrl.text.trim();
      request.fields['type'] = _selectedType;
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['stock'] = _stockCtrl.text.trim();
      request.fields['price'] = _priceCtrl.text.trim();

      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _pickedImage!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      if (!mounted) return;

      final isSuccess =
          (_isEdit && response.statusCode == 200) ||
          (!_isEdit && response.statusCode == 201);

      if (isSuccess) {
        Navigator.pop(context);
        CustomToast.showTopToast(
          context,
          _isEdit
              ? 'Item "${_nameCtrl.text.trim()}" updated!'
              : 'Item "${_nameCtrl.text.trim()}" created!',
          AppColors.success,
        );
        widget.onSuccess();
      } else {
        final message = body['message'] ?? (_isEdit ? 'Update failed' : 'Create failed');
        CustomToast.showTopToast(context, message, AppColors.error);
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.showTopToast(
        context,
        'Network error. Please try again.',
        AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                _isEdit ? 'Edit Item' : 'Add New Item',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 20),

              // Image picker
              _buildImagePicker(),
              const SizedBox(height: 16),

              // Name
              CustomTextField(
                label: 'Item Name',
                placeholder: 'e.g. Aquila Favonia',
                controller: _nameCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              // Type dropdown
              _buildTypeDropdown(),
              const SizedBox(height: 12),

              // Description
              _buildDescriptionField(),
              const SizedBox(height: 12),

              // Stock & Price (side by side)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Stock',
                      placeholder: 'e.g. 10',
                      controller: _stockCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1) return 'Min 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Price',
                      placeholder: 'e.g. 500',
                      controller: _priceCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1) return 'Min 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                label: _isLoading
                    ? (_isEdit ? 'Saving...' : 'Creating...')
                    : (_isEdit ? 'Save Changes' : 'Create Item'),
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final String existingPath = widget.item?['image'] ?? '';
    final String existingUrl = widget.baseUrl + existingPath;
    final bool hasExisting = _isEdit && existingPath.isNotEmpty;
    final bool hasNew = _pickedImage != null;

    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (hasNew || hasExisting) ? AppColors.primary : AppColors.border,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: hasNew
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              )
            : hasExisting
                ? Image.network(
                    existingUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to add image (optional)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Item Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
              color: AppColors.primaryDark,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
            color: AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: 'weapon', child: Text('Weapon')),
            DropdownMenuItem(value: 'artifact', child: Text('Artifact')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedType = v);
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descCtrl,
          maxLines: 2,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
            color: AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            hintText: 'Enter description (optional)',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminItemTile extends StatelessWidget {
  final dynamic item;
  final String baseUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminItemTile({
    required this.item,
    required this.baseUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = item['image'] ?? '';
    final String fullImageUrl = baseUrl + imagePath;
    final String rawPrice = item['price']?.toString() ?? '0';
    final int displayPrice = double.tryParse(rawPrice)?.toInt() ?? 0;
    final int stock = int.tryParse(item['stock']?.toString() ?? '') ?? 0;
    final String type = (item['type'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imagePath.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ebGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset('assets/images/primogem.png',
                          width: 16, height: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$displayPrice',
                        style: GoogleFonts.ebGaramond(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Stock: $stock',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.primary,
                  onTap: onEdit,
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.border,
      child: const Icon(
        Icons.broken_image,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
