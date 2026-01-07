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

class _PackageEditorState extends State<PackageEditor> {
  // Controllers
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _duration;
  late TextEditingController _discount;
  late TextEditingController _featureNameController;
  late TextEditingController _featureLimitController;

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
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _duration = TextEditingController(text: e?.durationDays.toString() ?? '');
    _discount = TextEditingController(text: e?.discount?.toString() ?? '');
    _featureNameController = TextEditingController();
    _featureLimitController = TextEditingController();

    features = List.from(e?.features ?? []);
    id = e?.id ?? widget.generateId();
    startDate = e?.startDate;
    status = e?.status ?? PackageStatus.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _duration.dispose();
    _discount.dispose();
    _featureNameController.dispose();
    _featureLimitController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  void _addFeature() {
    final name = _featureNameController.text.trim();
    final limit = int.tryParse(_featureLimitController.text.trim()) ?? 0;

    if (name.isNotEmpty) {
      setState(() {
        features.add(PackageFeature(
          feature: name,
          featureAr: name,
          limitCount: limit,
        ));
        _featureNameController.clear();
        _featureLimitController.clear();
      });
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: Locale(widget.isArabic ? 'ar' : 'en'),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final pkg = Package(
      name: _name.text.trim(),
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

  // --- UI Components ---

  InputDecoration _inputStyle(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark, themeColor!),
              const SizedBox(height: 20),

              // Name & Status Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _name,
                      decoration: _inputStyle(widget.isArabic ? 'اسم الباقة *' : 'Package Name *', isDark),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? (widget.isArabic ? 'الرجاء إدخال اسم' : 'Please enter a name') : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusToggle(isDark),
                ],
              ),
              const SizedBox(height: 16),

              // Price & Duration Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle(widget.isArabic ? 'السعر *' : 'Price *', isDark),
                      validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                          ? (widget.isArabic ? 'سعر غير صالح' : 'Invalid price') : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle(widget.isArabic ? 'مدة (يوم) *' : 'Duration (days) *', isDark),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                          ? (widget.isArabic ? 'مدة غير صالحة' : 'Invalid duration') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _discount,
                keyboardType: TextInputType.number,
                decoration: _inputStyle(widget.isArabic ? 'خصم (اختياري)' : 'Discount (optional)', isDark),
              ),
              const Divider(height: 32),

              // Features Section
              _buildFeatureInput(isDark),
              const SizedBox(height: 16),

              // Date Picker Section
              _buildDatePicker(isDark, themeColor),

              const Divider(height: 32),

              // Preview Section
              Text(
                widget.isArabic ? 'معاينة الباقة' : 'Package Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor),
              ),
              const SizedBox(height: 12),
              _buildLivePreview(isDark),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.green[800] : Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.existing == null
                        ? (widget.isArabic ? 'أنشئ الباقة' : 'Create Package')
                        : (widget.isArabic ? 'حفظ التعديلات' : 'Save Changes'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color themeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.existing == null
              ? (widget.isArabic ? 'إضافة باقة جديدة' : 'Add New Package')
              : (widget.isArabic ? 'تعديل الباقة' : 'Edit Package'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor),
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildStatusToggle(bool isDark) {
    bool isActive = status == PackageStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green : Colors.grey),
      ),
      child: Row(
        children: [
          Text(isActive
              ? (widget.isArabic ? 'نشط' : 'Active')
              : (widget.isArabic ? 'معطل' : 'Paused'),
            style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(isActive ? Icons.pause_circle : Icons.play_circle_fill),
            color: isActive ? Colors.green : Colors.grey,
            onPressed: () => setState(() => status = isActive ? PackageStatus.paused : PackageStatus.active),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureInput(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextFormField(
              controller: _featureNameController,
              decoration: _inputStyle(widget.isArabic ? 'اسم الميزة' : 'Feature Name', isDark),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(
              controller: _featureLimitController,
              keyboardType: TextInputType.number,
              decoration: _inputStyle(widget.isArabic ? 'الحد' : 'Limit', isDark),
              onFieldSubmitted: (_) => _addFeature(),
            )),
            IconButton(
              icon: const Icon(Icons.add_box, size: 40, color: Colors.green),
              onPressed: _addFeature,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark, Color themeColor) {
    return Row(
      children: [
        Icon(Icons.calendar_month, color: themeColor),
        const SizedBox(width: 8),
        Text(widget.isArabic ? 'تاريخ البداية:' : 'Start Date:', style: TextStyle(color: themeColor)),
        const SizedBox(width: 8),
        Text(
          startDate != null ? DateFormat('yyyy/MM/dd').format(startDate!) : (widget.isArabic ? 'الآن' : 'Now'),
          style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
        ),
        const Spacer(),
        TextButton(onPressed: _pickStartDate, child: Text(widget.isArabic ? 'تغيير' : 'Change')),
        if (startDate != null)
          IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setState(() => startDate = null)),
      ],
    );
  }

  Widget _buildLivePreview(bool isDark) {
    return PackageCardPreview(
      isDark: isDark,
      isArabic: widget.isArabic,
      package: Package(
        name: _name.text.isEmpty ? (widget.isArabic ? 'اسم الباقة' : 'Package Name') : _name.text,
        id: id,
        price: double.tryParse(_price.text) ?? 0,
        durationDays: int.tryParse(_duration.text) ?? 0,
        discount: double.tryParse(_discount.text),
        features: features,
        subscribers: widget.existing?.subscribers ?? 0,
        status: status,
        startDate: startDate,
        isArchived: widget.existing?.isArchived ?? false,
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.green.shade900, Colors.green.shade700]
                : [Colors.blue.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(package.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor)),
                if (package.discount != null)
                  Chip(label: Text('${package.discount}% OFF'), backgroundColor: Colors.redAccent, labelStyle: const TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${isArabic ? 'السعر' : 'Price'}: ${package.price} SAR', style: TextStyle(color: themeColor)),
            Text('${isArabic ? 'المدة' : 'Duration'}: ${package.durationDays} ${isArabic ? 'يوم' : 'Days'}', style: TextStyle(color: themeColor)),
            const Divider(),
            Wrap(
              spacing: 8,
              children: package.features.map((f) => Chip(
                backgroundColor: isDark ? Colors.white10 : Colors.blue.shade50,
                label: Text('${f.feature} (${f.limitCount})', style: TextStyle(fontSize: 12, color: themeColor)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}