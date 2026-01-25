import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/WithdrawalRequest.dart';
import '../../core/report_download.dart';
import '../../providers/app_providers.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<WithdrawalRequest>> pendingFuture;
  late Future<List<WithdrawalRequest>> historyFuture;

  // متغيرات الفلترة والبحث
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  String? _selectedRole;
  RangeValues _pointsRange = const RangeValues(0, 10000);
  String? _selectedStatus;
  bool _showFilters = false;

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // ألوان خضراء للوضع الداكن
      return {
        'primary': const Color(0xFF1B5E20),           // أخضر داكن جداً
        'secondary': const Color(0xFF4CAF50),         // أخضر متوسط
        'accent': const Color(0xFF81C784),           // أخضر فاتح
        'background': const Color(0xFF121212),       // خلفية داكنة
        'card': const Color(0xFF1E1E1E),             // كارت داكن
        'surface': const Color(0xFF2D2D2D),          // سطح داكن
        'text': const Color(0xFFE0E0E0),             // نص فاتح
        'textSecondary': const Color(0xFFB0B0B0),    // نص ثانوي
        'success': const Color(0xFF4CAF50),          // نجاح
        'error': Colors.redAccent,                   // خطأ
        'warning': Colors.orange,                    // تحذير
        'gradientStart': const Color(0xFF1B5E20),    // تدرج بداية
        'gradientEnd': const Color(0xFF2E7D32),      // تدرج نهاية
      };
    } else {
      // ألوان زرقاء للوضع الفاتح
      return {
        'primary': const Color(0xFF0F172A),          // أزرق داكن
        'secondary': const Color(0xFF1E293B),        // أزرق داكن متوسط
        'accent': const Color(0xFF3B82F6),           // أزرق فاتح
        'background': const Color(0xFFF8FAFC),       // خلفية فاتحة
        'card': Colors.white,                        // كارت أبيض
        'surface': Colors.white,                     // سطح أبيض
        'text': const Color(0xFF1E293B),             // نص داكن
        'textSecondary': const Color(0xFF64748B),    // نص ثانوي
        'success': Colors.green,                     // نجاح
        'error': Colors.redAccent,                   // خطأ
        'warning': Colors.orange,                    // تحذير
        'gradientStart': const Color(0xFF4FA8ED),    // تدرج بداية
        'gradientEnd': const Color(0xFF1F61CD),      // تدرج نهاية
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    pendingFuture = WithdrawalsService.fetchPending();
    historyFuture = WithdrawalsService.fetchHistory();
  }

  void reload() {
    setState(() => _loadData());
  }

  List<WithdrawalRequest> _applyFilters(List<WithdrawalRequest> items) {
    var filtered = items;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.marketerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            item.supervisorName.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_dateRange != null) {
      filtered = filtered.where((item) {
        final date = item.requestedAt ?? DateTime.now();
        return date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_selectedRole != null) {
      filtered = filtered.where((item) => item.marketerName == item.supervisorName).toList();
    }

    filtered = filtered.where((item) {
      return item.points >= _pointsRange.start && item.points <= _pointsRange.end;
    }).toList();

    if (_selectedStatus != null) {
      filtered = filtered.where((item) => item.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    final colors = _getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors['background'],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: reload,
        backgroundColor: colors['secondary'],
        icon: Icon(Icons.refresh_rounded, color: colors['card']),
        label: Text(
          isArabic ? 'تحديث' : 'Refresh',
          style: TextStyle(color: colors['card'], fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 40.0,
            floating: false,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors['gradientStart']!, colors['gradientEnd']!],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: CircleAvatar(radius: 80, backgroundColor: colors['card']!.withOpacity(0.03)),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            actions: const [SizedBox(width: 30)],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                margin: const EdgeInsets.fromLTRB(11, 0, 11, 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colors['card'],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: colors['text'],
                  unselectedLabelColor: colors['card']!.withOpacity(0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: isArabic ? 'المعلقة' : 'Pending'),
                    Tab(text: isArabic ? 'السجل' : 'History'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildSearchAndFilterBar(isArabic, colors),
            if (_showFilters) _buildFiltersPanel(isArabic, colors),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(pendingFuture, isArabic, colors, showActions: true),
                  _buildListView(historyFuture, isArabic, colors, showActions: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(bool isArabic, Map<String, Color> colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: colors['surface']!.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: TextStyle(
                fontSize: 14,
                color: colors['text'],
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: isArabic ? 'البحث بالاسم...' : 'Search by name...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colors['textSecondary'],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: colors['textSecondary'],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: colors['textSecondary'],
                  ),
                  onPressed: () => setState(() => _searchController.clear()),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _buildFilterIcon(isArabic, colors),
          _buildPdfExportIcon(isArabic, colors),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Map<String, Color> colors,
    Color? bgColor,
    Color? iconColor,
    String? tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: bgColor ?? colors['surface']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors['surface']!.withOpacity(0.2),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(
          icon,
          size: 20,
          color: iconColor ?? colors['text'],
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildFilterIcon(bool isArabic, Map<String, Color> colors) {
    return _buildIconButton(
      icon: Icons.filter_list_rounded,
      colors: colors,
      bgColor: _showFilters ? colors['accent'] : colors['surface']!.withOpacity(0.1),
      iconColor: _showFilters ? colors['card'] : colors['text'],
      tooltip: isArabic ? 'فلترة' : 'Filters',
      onTap: () => setState(() => _showFilters = !_showFilters),
    );
  }

  Widget _buildPdfExportIcon(bool isArabic, Map<String, Color> colors) {
    return _buildIconButton(
      icon: Icons.picture_as_pdf_rounded,
      colors: colors,
      bgColor: colors['error']!.withOpacity(0.1),
      iconColor: colors['error'],
      tooltip: isArabic ? 'تصدير PDF' : 'PDF',
      onTap: () => ReportDownload.downloadReport(
        'pdf',
        dateRange: _dateRange,
        role: _selectedRole,
        status: _selectedStatus,
        pointsRange: _pointsRange,
      ),
    );
  }

  Future<void> _showCompactDateRangePicker(bool isArabic, Map<String, Color> colors) async {
    DateTime? start = _dateRange?.start;
    DateTime? end = _dateRange?.end;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: colors['card'],
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? 'اختر التاريخ' : 'Select Date Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors['text'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CalendarDatePicker(
                    initialDate: start ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    onDateChanged: (date) {
                      if (start == null || (start != null && end != null)) {
                        start = date;
                        end = null;
                      } else {
                        end = date;
                        if (end!.isBefore(start!)) {
                          final temp = start;
                          start = end;
                          end = temp;
                        }
                        setState(() {
                          _dateRange = DateTimeRange(start: start!, end: end!);
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                  if (start != null && end == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        isArabic ? 'اختر تاريخ النهاية' : 'Select End Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors['textSecondary'],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersPanel(bool isArabic, Map<String, Color> colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colors['surface']!.withOpacity(0.1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'الفلاتر' : 'Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors['text'],
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterSection(
              isArabic ? 'التاريخ' : 'Date',
              Icons.calendar_today,
              InkWell(
                onTap: () => _showCompactDateRangePicker(isArabic, colors),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors['surface']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _dateRange != null ? colors['accent']! : colors['surface']!.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 20, color: colors['accent']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateRange == null
                              ? (isArabic ? 'اختر نطاق التاريخ' : 'Select Date Range')
                              : '${_dateRange!.start.toString().split(' ')[0]}'
                              ' - ${_dateRange!.end.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors['text'],
                          ),
                        ),
                      ),
                      if (_dateRange != null)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18, color: colors['textSecondary']),
                          onPressed: () => setState(() => _dateRange = null),
                        ),
                    ],
                  ),
                ),
              ),
              colors,
            ),
            const SizedBox(height: 12),
            _buildFilterSection(
              isArabic ? 'الدور' : 'Role',
              Icons.people,
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip(isArabic ? 'مشرف' : 'Supervisor', 'supervisor', _selectedRole, isArabic, colors),
                  _buildChip(isArabic ? 'مسوق' : 'Marketer', 'marketer', _selectedRole, isArabic, colors),
                ],
              ),
              colors,
            ),
            const SizedBox(height: 12),
            _buildFilterSection(
              isArabic ? 'الحالة' : 'State',
              Icons.info_outline,
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip(isArabic ? 'معلق' : 'Pending', 'pending', _selectedStatus, isArabic, colors, color: colors['warning']),
                  _buildChip(isArabic ? 'مكتمل' : 'Approved', 'approved', _selectedStatus, isArabic, colors, color: colors['success']),
                  _buildChip(isArabic ? 'مرفوض' : 'Rejected', 'rejected', _selectedStatus, isArabic, colors, color: colors['error']),
                ],
              ),
              colors,
            ),
            const SizedBox(height: 12),
            _buildFilterSection(
              isArabic ? 'نطاق النقاط (${_pointsRange.start.toInt()} - ${_pointsRange.end.toInt()})'
                  : 'Point range (${_pointsRange.start.toInt()} - ${_pointsRange.end.toInt()})',
              Icons.auto_awesome,
              RangeSlider(
                values: _pointsRange,
                min: 0,
                max: 10000,
                divisions: 100,
                activeColor: colors['accent'],
                inactiveColor: colors['surface']!.withOpacity(0.3),
                labels: RangeLabels(
                  _pointsRange.start.toInt().toString(),
                  _pointsRange.end.toInt().toString(),
                ),
                onChanged: (values) => setState(() => _pointsRange = values),
              ),
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colors['textSecondary']),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: colors['textSecondary'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildChip(String label, String value, String? selectedValue, bool isArabic, Map<String, Color> colors,
      {Color? color}) {
    final isSelected = selectedValue == value;
    final chipColor = color ?? colors['accent']!;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'مشرف' || label == 'مسوق' || label == 'Supervisor' || label == 'Marketer') {
            _selectedRole = selected ? value : null;
          } else {
            _selectedStatus = selected ? value : null;
          }
        });
      },
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : colors['text'],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? chipColor : colors['surface']!.withOpacity(0.3)),
    );
  }

  Widget _buildListView(Future<List<WithdrawalRequest>> future, bool isArabic, Map<String, Color> colors,
      {required bool showActions}) {
    return FutureBuilder<List<WithdrawalRequest>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colors['accent']));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildStatusEmpty(Icons.receipt_long_outlined, isArabic ? 'لا توجد بيانات حالياً' : 'No data available', colors);
        }

        final items = _applyFilters(snapshot.data!);

        if (items.isEmpty) {
          return _buildStatusEmpty(Icons.filter_list_off, isArabic ? 'لا توجد نتائج مطابقة للفلاتر' : 'No matching results', colors);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: items.length,
          itemBuilder: (context, i) => _buildModernCard(items[i], showActions, isArabic, colors),
        );
      },
    );
  }

  Widget _buildModernCard(WithdrawalRequest w, bool showActions, bool isArabic, Map<String, Color> colors) {
    final bool isPending = w.status == 'pending' || w.status == null;
    final bool isApproved = w.status == 'approved';
    final bool isRejected = w.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: colors['surface']!.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors['accent']!.withOpacity(0.1),
                  child: Text(
                    w.marketerName[0].toUpperCase(),
                    style: TextStyle(
                      color: colors['accent'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.marketerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors['text'],
                        ),
                      ),
                      Text(
                        isArabic ? 'بإشراف: ${w.supervisorName}' : 'Supervisor: ${w.supervisorName}',
                        style: TextStyle(
                          color: colors['textSecondary'],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isArabic ? '${w.amount} ر.س ' : '${w.amount} SAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colors['success'],
                      ),
                    ),
                    _buildStatusText(w.status, isArabic, colors),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: colors['surface']!.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDataLine(Icons.auto_awesome, isArabic ? 'النقاط المستبدلة' : 'Replaced Points',
                    isArabic ? '${w.points} نقطة' : '${w.points} points', colors['warning']!, colors),
                _buildDataLine(Icons.account_balance, isArabic ? 'البنك المستلم' : 'Bank', w.bank, colors['accent']!, colors),
                _buildDataLine(Icons.credit_card, isArabic ? 'رقم الحساب' : 'IBAN', w.accountNumber, colors['textSecondary']!, colors),
                if (isRejected && w.rejectReason != null)
                  _buildDataLine(Icons.info_outline, isArabic ? 'سبب الرفض' : 'Reject Reason', w.rejectReason!, colors['error']!, colors),
                if (isApproved && w.payout != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors['success']!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors['success']!.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDataLine(Icons.payments, isArabic ? 'طريقة الدفع' : 'Payment Method', w.payout!.paymentMethod,
                            colors['success']!, colors),
                        _buildDataLine(Icons.confirmation_number, isArabic ? 'رقم المرجع' : 'Reference Number',
                            w.payout!.referenceNumber, colors['success']!, colors),
                        _buildDataLine(Icons.calendar_today, isArabic ? 'تاريخ الصرف' : 'Payment Date',
                            w.payout!.paidAt.toString().split(' ')[0], colors['success']!, colors),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveDialog(w, isArabic, colors),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors['accent'],
                        foregroundColor: colors['card'],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isArabic ? 'اعتماد وصرف' : 'Accept',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _rejectDialog(w, isArabic, colors),
                    icon: const Icon(Icons.close_rounded),
                    color: colors['error'],
                    style: IconButton.styleFrom(
                      backgroundColor: colors['error']!.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataLine(IconData icon, String label, String value, Color color, Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors['textSecondary'],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors['text'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(String? status, bool isArabic, Map<String, Color> colors) {
    String text = isArabic ? 'قيد الانتظار' : 'Pending';
    Color color = colors['warning']!;
    if (status == 'approved') {
      text = isArabic ? 'تم الصرف' : 'Paid';
      color = colors['success']!;
    }
    if (status == 'rejected') {
      text = isArabic ? 'مرفوض' : 'Rejected';
      color = colors['error']!;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildStatusEmpty(IconData icon, String msg, Map<String, Color> colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: colors['surface']!.withOpacity(0.5),
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            style: TextStyle(color: colors['textSecondary']),
          ),
        ],
      ),
    );
  }

  void _approveDialog(WithdrawalRequest w, bool isArabic, Map<String, Color> colors) {
    final methodCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors['card'],
        surfaceTintColor: colors['card'],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colors['accent']!.withOpacity(0.1),
              child: Icon(
                Icons.payments_outlined,
                color: colors['accent'],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تأكيد الدفع' : 'Accept',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: colors['text'],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'يرجى إدخال بيانات التحويل لإتمام العملية بنجاح'
                    : 'Please enter the transfer details to complete the operation successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors['textSecondary'],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: methodCtrl,
                style: TextStyle(color: colors['text']),
                decoration: InputDecoration(
                  labelText: isArabic ? 'طريقة الدفع' : 'Payment Method',
                  hintText: isArabic ? 'مثلاً: تحويل بنكي، STC Pay' : 'Example: bank transfer, STC Pay',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: colors['textSecondary']),
                  filled: true,
                  fillColor: colors['surface']!.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors['surface']!.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors['surface']!.withOpacity(0.2)),
                  ),
                  labelStyle: TextStyle(color: colors['textSecondary']),
                  hintStyle: TextStyle(color: colors['textSecondary']!.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: refCtrl,
                style: TextStyle(color: colors['text']),
                decoration: InputDecoration(
                  labelText: isArabic ? 'رقم المرجع' : 'Reference Number',
                  hintText: isArabic ? 'أدخل رقم العملية' : 'Enter the operation number',
                  prefixIcon: Icon(Icons.tag_rounded, color: colors['textSecondary']),
                  filled: true,
                  fillColor: colors['surface']!.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors['surface']!.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors['surface']!.withOpacity(0.2)),
                  ),
                  labelStyle: TextStyle(color: colors['textSecondary']),
                  hintStyle: TextStyle(color: colors['textSecondary']!.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: colors['surface']!.withOpacity(0.3)),
                  ),
                  child: Text(
                    isArabic ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: colors['textSecondary']),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await WithdrawalsService.approve(w.id, methodCtrl.text, refCtrl.text);
                    reload();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors['accent'],
                    foregroundColor: colors['card'],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isArabic ? 'تأكيد الدفع' : 'Accept',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _rejectDialog(WithdrawalRequest w, bool isArabic, Map<String, Color> colors) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors['card'],
        title: Text(
          isArabic ? 'رفض الطلب ❌' : 'Reject Request',
          style: TextStyle(color: colors['text']),
        ),
        content: TextField(
          controller: reasonCtrl,
          style: TextStyle(color: colors['text']),
          decoration: InputDecoration(
            labelText: isArabic ? 'سبب الرفض' : 'Reject Reason',
            labelStyle: TextStyle(color: colors['textSecondary']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['surface']!.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['surface']!.withOpacity(0.2)),
            ),
            filled: true,
            fillColor: colors['surface']!.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: colors['textSecondary']),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await WithdrawalsService.reject(w.id, reasonCtrl.text);
              reload();
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors['error']),
            child: Text(
              isArabic ? 'رفض' : 'Reject',
              style: TextStyle(color: colors['card']),
            ),
          ),
        ],
      ),
    );
  }
}