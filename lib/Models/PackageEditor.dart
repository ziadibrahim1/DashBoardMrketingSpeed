import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dashboard/pages/FlexManagement.dart';
import '../dashboard/pages/Package.dart';
import '../services/api_service.dart';

class PackageEditor extends StatefulWidget {
  final Package? existing;
  final int Function() generateId;
  final void Function(Package) onSave;
  final bool isArabic;

  const PackageEditor({
    super.key,
    this.existing,
    required this.generateId,
    required this.onSave,
    required this.isArabic,
  });

  @override
  State<PackageEditor> createState() => _PackageEditorState();
}

class _PackageEditorState extends State<PackageEditor> with TickerProviderStateMixin {
  // Controllers
  late TextEditingController _nameAr;
  late TextEditingController _nameEn;
  late TextEditingController _price;
  late TextEditingController _duration;
  late TextEditingController _discount;
  late TextEditingController _featureNameArController;
  late TextEditingController _featureNameEnController;
  late TextEditingController _featureLimitController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int categoryId = 1;
  bool _isEnglish = true;

  // State Variables
  List<PackageFeature> features = [];
  late int id;
  DateTime? startDate;
  PackageStatus status = PackageStatus.active;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameAr = TextEditingController(text: e?.nameAr ?? '');
    _nameEn = TextEditingController(text:e?.nameEn ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _duration = TextEditingController(text: e?.durationDays.toString() ?? '');
    _discount = TextEditingController(text: e?.discount?.toString() ?? '');
    _featureNameArController = TextEditingController();
    _featureNameEnController = TextEditingController();
    _featureLimitController = TextEditingController();
    categoryId = widget.existing?.CategoryId ?? 1;
    features = List.from(e?.features ?? []);
    id = e?.id ?? widget.generateId();
    startDate = e?.startDate;
    status = e?.status ?? PackageStatus.active;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _price.dispose();
    _duration.dispose();
    _discount.dispose();
    _featureNameArController.dispose();
    _featureNameEnController.dispose();
    _featureLimitController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addFeature() {
    final nameAr = _featureNameArController.text.trim();
    final nameEn = _featureNameEnController.text.trim();
    final limit = int.tryParse(_featureLimitController.text.trim()) ?? 0;

    if (nameAr.isNotEmpty || nameEn.isNotEmpty) {
      setState(() {
        features.add(PackageFeature(
          feature: nameAr,
          featureAr: nameAr,
          featureEn: nameEn,
          limitCount: limit,
        ));
        _featureNameArController.clear();
        _featureNameEnController.clear();
        _featureLimitController.clear();
      });
    }
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A3A2E), const Color(0xFF0F2922)]
              : [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFD7EFDC).withOpacity(0.2) : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isArabic ? 'فئة الباقة' : 'Package Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryOption(
                  value: 1,
                  label: widget.isArabic ? 'أساسية' : 'Basic',
                  icon: Icons.star_rounded,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryOption(
                  value: 2,
                  label: widget.isArabic ? 'إضافية' : 'Extra',
                  icon: Icons.workspace_premium_rounded,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption({
    required int value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = categoryId == value;
    return InkWell(
      onTap: () => setState(() => categoryId = value),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.3 : 0.2)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: Locale(widget.isArabic ? 'ar' : 'en'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final pkg = Package(
      nameAr: _nameAr.text.trim(),
      nameEn: _nameEn.text.trim(),
      id: id,
      price: double.parse(_price.text.trim()),
      durationDays: int.parse(_duration.text.trim()),
      discount: _discount.text.trim().isEmpty ? null : double.parse(_discount.text.trim()),
      features: features,
      subscribers: widget.existing?.subscribers ?? 0,
      status: status,
      startDate: startDate,
      isArchived: widget.existing?.isArchived ?? false,
      logs: widget.existing?.logs ?? [],
      lastZeroSubscriberDetected: widget.existing?.lastZeroSubscriberDetected,
      CategoryId: categoryId,
    );

    pkg.addLog(widget.existing == null
        ? (widget.isArabic ? 'إنشاء باقة جديدة' : 'Created new package')
        : (widget.isArabic ? 'تعديل باقة' : 'Edited package'));

    if (widget.existing == null) {
      await ApiService.createPackage(pkg, widget.isArabic);
    } else {
      await ApiService.savePackage(pkg, widget.isArabic);
    }

    widget.onSave(pkg);
    Navigator.pop(context);
  }

  InputDecoration _modernInputStyle(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[700],
      ),
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.blue.shade100,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade700,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernHeader(isDark),
                  const SizedBox(height: 24),

                  // Name & Status Section
                  _buildNameStatusCard(isDark),
                  const SizedBox(height: 20),

                  // Category Selector
                  _buildCategorySelector(isDark),
                  const SizedBox(height: 20),

                  // Price & Duration Card
                  _buildPriceDurationCard(isDark),
                  const SizedBox(height: 20),

                  // Discount Card
                  _buildDiscountCard(isDark),
                  const SizedBox(height: 20),

                  // Features Section
                  _buildFeaturesCard(isDark),
                  const SizedBox(height: 20),

                  // Date Picker Card
                  _buildDateCard(isDark),
                  const SizedBox(height: 20),

                  // Preview Section
                  _buildPreviewSection(isDark),
                  const SizedBox(height: 24),

                  // Save Button
                  _buildModernSaveButton(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.green.shade900, Colors.green.shade800]
              : [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              widget.existing == null ? Icons.add_box_rounded : Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.existing == null
                  ? (widget.isArabic ? 'إضافة باقة جديدة' : 'Add New Package')
                  : (widget.isArabic ? 'تعديل الباقة' : 'Edit Package'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameAr,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: _modernInputStyle(
              widget.isArabic ? 'اسم الباقة بالعربية' : 'Package Arabic Name *',
              Icons.inventory_2_rounded,
              isDark,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? (widget.isArabic ? 'الرجاء إدخال اسم' : 'Please enter a name')
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameEn,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: _modernInputStyle(
              widget.isArabic ? 'اسم الباقة بالإنجليزبة' : 'Package English Name *',
              Icons.inventory_2_rounded,
              isDark,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? (widget.isArabic ? 'الرجاء إدخال اسم' : 'Please enter a name')
                : null,
          ),
          const SizedBox(height: 16),
          _buildEnhancedStatusToggle(isDark),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatusToggle(bool isDark) {
    bool isActive = status == PackageStatus.active;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isActive ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            isActive
                ? (widget.isArabic ? 'نشط' : 'Active')
                : (widget.isArabic ? 'معطل' : 'Paused'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isActive,
            onChanged: (v) => setState(() => status = v ? PackageStatus.active : PackageStatus.paused),
            activeColor: Colors.white,
            activeTrackColor: Colors.green.shade300,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPriceDurationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: _modernInputStyle(
                widget.isArabic ? 'السعر *' : 'Price *',
                Icons.payments_rounded,
                isDark,
              ),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                  ? (widget.isArabic ? 'سعر غير صالح' : 'Invalid price')
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _duration,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: _modernInputStyle(
                widget.isArabic ? 'مدة (يوم) *' : 'Duration (days) *',
                Icons.schedule_rounded,
                isDark,
              ),
              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                  ? (widget.isArabic ? 'مدة غير صالحة' : 'Invalid duration')
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.red.shade900.withOpacity(0.3), Colors.orange.shade900.withOpacity(0.3)]
              : [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _discount,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: _modernInputStyle(
          widget.isArabic ? 'خصم (اختياري)' : 'Discount (optional)',
          Icons.local_offer_rounded,
          isDark,
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(bool isDark) {
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFD7EFDC).withOpacity(0.2) : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isArabic ? 'الميزات' : 'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _featureNameArController,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _modernInputStyle(
                    widget.isArabic ? ' اسم الميزة بالعربيه' : 'Feature Arabic Name',
                    Icons.text_fields_rounded,
                    isDark,
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _featureLimitController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _modernInputStyle(
                    widget.isArabic ? 'الحد' : 'Limit',
                    Icons.pin_rounded,
                    isDark,
                  ),
                  onFieldSubmitted: (_) => _addFeature(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
                  onPressed: _addFeature,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _featureNameEnController,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _modernInputStyle(
                    widget.isArabic ? 'اسم الميزة بالانجليزية' : 'Feature English Name',
                    Icons.text_fields_rounded,
                    isDark,
                  ),
                ),
              ),
            ],
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...features.asMap().entries.map((entry) {
              int index = entry.key;
              PackageFeature feature = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)]
                        : [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${feature.feature}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${widget.isArabic ? 'الحد' : 'Limit'}: ${feature.limitCount}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          features.removeAt(index);
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCard(bool isDark) {
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.purple.shade900.withOpacity(0.3), Colors.blue.shade900.withOpacity(0.3)]
              : [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.purple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFD7EFDC).withOpacity(0.2) : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_rounded,
                  color: themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isArabic ? 'تاريخ البداية' : 'Start Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.purple.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: themeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        startDate != null
                            ? DateFormat('yyyy/MM/dd').format(startDate!)
                            : (widget.isArabic ? 'الآن' : 'Now'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_calendar_rounded, color: Colors.white),
                  onPressed: _pickStartDate,
                  tooltip: widget.isArabic ? 'تغيير' : 'Change',
                ),
              ),
              if (startDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.red),
                    onPressed: () => setState(() => startDate = null),
                    tooltip: widget.isArabic ? 'مسح' : 'Clear',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(bool isDark) {
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.amber.shade900, Colors.orange.shade900]
                  : [Colors.amber.shade100, Colors.orange.shade100],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                color: themeColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                widget.isArabic ? 'معاينة الباقة' : 'Package Preview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEnhancedPreview(isDark),
      ],
    );
  }

  Widget _buildEnhancedPreview(bool isDark) {
    return PackageCardPreview(
      isDark: isDark,
      isArabic: widget.isArabic,
      package: Package(
        nameAr: _nameAr.text.isEmpty ? (widget.isArabic ? ' اسم الباقة بالعربي' : 'Package Arabic Name') : _nameAr.text,
        nameEn: _nameEn.text.isEmpty ? (widget.isArabic ? 'اسم الباقة بالانجليزية' : 'Package English Name') : _nameEn.text,
        id: id,
        price: double.tryParse(_price.text) ?? 0,
        durationDays: int.tryParse(_duration.text) ?? 0,
        discount: double.tryParse(_discount.text),
        features: features,
        subscribers: widget.existing?.subscribers ?? 0,
        status: status,
        startDate: startDate,
        isArchived: widget.existing?.isArchived ?? false,
        CategoryId: categoryId,
      ),
    );
  }

  Widget _buildModernSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.green.shade700, Colors.green.shade900]
              : [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.green.withOpacity(0.4) : Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.existing == null ? Icons.add_circle_rounded : Icons.save_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              widget.existing == null
                  ? (widget.isArabic ? 'أنشئ الباقة' : 'Create Package')
                  : (widget.isArabic ? 'حفظ التعديلات' : 'Save Changes'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageCardPreview extends StatelessWidget {
  final Package package;
  final bool isArabic;
  final bool isDark;

  const PackageCardPreview({
    super.key,
    required this.package,
    required this.isArabic,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                const Color(0xFF1A3A2E),
                const Color(0xFF16502D),
                const Color(0xFF0F2922),
              ]
                  : [
                Colors.white,
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Name and Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: package.CategoryId == 1
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                package.CategoryId == 1
                                    ? Icons.star_rounded
                                    : Icons.workspace_premium_rounded,
                                size: 16,
                                color: package.CategoryId == 1 ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                package.CategoryId == 1
                                    ? (isArabic ? 'أساسية' : 'Basic')
                                    : (isArabic ? 'إضافية' : 'Extra'),
                                style: TextStyle(
                                  color: package.CategoryId == 1 ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          package.nameAr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          package.nameEn,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (package.discount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${package.discount}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Price and Duration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.payments_rounded,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'السعر' : 'Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              Text(
                                '${package.price} SAR',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? Colors.white12 : Colors.blue.shade200,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isArabic ? 'المدة' : 'Duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              Text(
                                '${package.durationDays} ${isArabic ? 'يوم' : 'Days'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (package.features.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
                const SizedBox(height: 16),

                // Features Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'الميزات المتضمنة' : 'Included Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Features List
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: package.features.map((f) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)]
                              : [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${f.feature}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${f.limitCount}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  }