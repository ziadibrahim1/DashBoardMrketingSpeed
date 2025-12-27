import 'package:flutter/material.dart';
import '../../core/WithdrawalRequest.dart';
import '../../core/report_download.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<WithdrawalRequest>> pendingFuture;
  late Future<List<WithdrawalRequest>> historyFuture;

  final Color primaryColor = const Color(0xFF0F172A);
  final Color accentColor = const Color(0xFF3B82F6);

  // متغيرات الفلترة والبحث
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  String? _selectedRole; // 'supervisor' أو 'marketer'
  RangeValues _pointsRange = const RangeValues(0, 10000);
  String? _selectedStatus; // 'approved', 'rejected', 'pending'
  bool _showFilters = false;

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

  // دالة تطبيق الفلاتر
  List<WithdrawalRequest> _applyFilters(List<WithdrawalRequest> items) {
    var filtered = items;

    // فلتر البحث بالاسم
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.marketerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            item.supervisorName.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // فلتر التاريخ
    if (_dateRange != null) {
      filtered = filtered.where((item) {
        final date = item.requestedAt ?? DateTime.now();
        return date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // فلتر الدور (ملاحظة: قد تحتاج لإضافة حقل role في WithdrawalRequest)
    if (_selectedRole != null) {
      // هنا يمكنك تطبيق الفلترة حسب الدور إذا كان متوفراً في البيانات
        filtered = filtered.where((item) => item.marketerName == item.supervisorName).toList();
    }

    // فلتر النقاط
    filtered = filtered.where((item) {
      return item.points >= _pointsRange.start && item.points <= _pointsRange.end;
    }).toList();

    // فلتر الحالة
    if (_selectedStatus != null) {
      filtered = filtered.where((item) => item.status == _selectedStatus).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _dateRange = null;
      _selectedRole = null;
      _pointsRange = const RangeValues(0, 10000);
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: reload,
        backgroundColor: const Color(0xFF317EBC),
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        label: const Text('تحديث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4FA8ED), Color(0xFF1F61CD)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.03)),
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  labelColor: const Color(0xFF1E293B),
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'المعلقة'),
                    Tab(text: 'السجل'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildSearchAndFilterBar(),
            if (_showFilters) _buildFiltersPanel(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(pendingFuture, showActions: true),
                  _buildListView(historyFuture, showActions: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // شريط البحث والفلترة
  Widget _buildSearchAndFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ↓
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true, // مهم
                hintText: 'البحث بالاسم...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () =>
                      setState(() => _searchController.clear()),
                )
                    : null,
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 8), // ↓
              ),
            ),
          ),
          const SizedBox(width: 6),

          _buildFilterIcon(),
          _buildPdfExportIcon(), // 👈 هنا أضفنا أيقونة التصدير
        ],
      ),
    );
  }
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color bgColor = Colors.grey,
    Color iconColor = Colors.black,
    String? tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: iconColor),
        onPressed: onTap,
      ),
    );
  }
  Widget _buildFilterIcon() {
    return _buildIconButton(
      icon: Icons.filter_list_rounded,
      bgColor: _showFilters ? accentColor : Colors.grey.shade200,
      iconColor: _showFilters ? Colors.white : Colors.grey.shade700,
      tooltip: 'فلترة',
      onTap: () => setState(() => _showFilters = !_showFilters),
    );
  }
  Widget _buildPdfExportIcon() {
    return _buildIconButton(
      icon: Icons.picture_as_pdf_rounded,
      bgColor: Colors.red.shade50,
      iconColor: Colors.red.shade600,
      tooltip: 'تصدير PDF',
      onTap: () => ReportDownload.downloadReport(
        'pdf',
        dateRange: _dateRange,
        role: _selectedRole,
        status: _selectedStatus,
        pointsRange: _pointsRange,
      ),
    );
  }


  Future<void> _showCompactDateRangePicker() async {
    DateTime? start = _dateRange?.start;
    DateTime? end = _dateRange?.end;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'اختر تاريخ النهاية',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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

  // لوحة الفلاتر
  Widget _buildFiltersPanel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = MediaQuery.of(context).size.height * 0.75; // 75% من الشاشة

        return Container(
          margin: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: maxHeight, // 👈 يمنع الطول الزائد
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: SingleChildScrollView( // 👈 الحل السحري
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'الفلاتر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // فلتر التاريخ
                _buildFilterSection(
                  'التاريخ',
                  Icons.calendar_today,
                    InkWell(
                      onTap: _showCompactDateRangePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _dateRange != null
                                ? accentColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range, size: 20, color: accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dateRange == null
                                    ? 'اختر نطاق التاريخ'
                                    : '${_dateRange!.start.toString().split(' ')[0]}'
                                    ' - ${_dateRange!.end.toString().split(' ')[0]}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            if (_dateRange != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _dateRange = null),
                              ),
                          ],
                        ),
                      ),
                    )


                ),

                const SizedBox(height: 12),

                // فلتر الدور
                _buildFilterSection(
                  'الدور',
                  Icons.people,
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildChip('مشرف', 'supervisor', _selectedRole),
                      _buildChip('مسوق', 'marketer', _selectedRole),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // فلتر الحالة
                _buildFilterSection(
                  'الحالة',
                  Icons.info_outline,
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildChip('معلق', 'pending', _selectedStatus,
                          color: Colors.orange),
                      _buildChip('مكتمل', 'approved', _selectedStatus,
                          color: Colors.green),
                      _buildChip('مرفوض', 'rejected', _selectedStatus,
                          color: Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // فلتر النقاط
                _buildFilterSection(
                  'نطاق النقاط (${_pointsRange.start.toInt()} - ${_pointsRange.end.toInt()})',
                  Icons.auto_awesome,
                  RangeSlider(
                    values: _pointsRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    activeColor: accentColor,
                    labels: RangeLabels(
                      _pointsRange.start.toInt().toString(),
                      _pointsRange.end.toInt().toString(),
                    ),
                    onChanged: (values) =>
                        setState(() => _pointsRange = values),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildChip(String label, String value, String? selectedValue, {Color? color}) {
    final isSelected = selectedValue == value;
    final chipColor = color ?? accentColor;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'مشرف' || label == 'مسوق') {
            _selectedRole = selected ? value : null;
          } else {
            _selectedStatus = selected ? value : null;
          }
        });
      },
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? chipColor : Colors.grey.shade300),
    );
  }

  bool _hasActiveFilters() {
    return _dateRange != null ||
        _selectedRole != null ||
        _selectedStatus != null ||
        _pointsRange.start != 0 ||
        _pointsRange.end != 10000;
  }

  Widget _buildReportBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildExportBtn(Icons.picture_as_pdf_rounded, 'PDF', Colors.red.shade600, () => ReportDownload.downloadReport('pdf')),
        ],
      ),
    );
  }

  Widget _buildExportBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(Future<List<WithdrawalRequest>> future, {required bool showActions}) {
    return FutureBuilder<List<WithdrawalRequest>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: accentColor));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildStatusEmpty(Icons.receipt_long_outlined, 'لا توجد بيانات حالياً');
        }

        final items = _applyFilters(snapshot.data!);

        if (items.isEmpty) {
          return _buildStatusEmpty(Icons.filter_list_off, 'لا توجد نتائج مطابقة للفلاتر');
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: items.length,
          itemBuilder: (context, i) => _buildModernCard(items[i], showActions),
        );
      },
    );
  }

  Widget _buildModernCard(WithdrawalRequest w, bool showActions) {
    final bool isPending = w.status == 'pending' || w.status == null;
    final bool isApproved = w.status == 'approved';
    final bool isRejected = w.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(w.marketerName[0].toUpperCase(),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.marketerName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('بإشراف: ${w.supervisorName}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${w.amount} ر.س',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green)),
                    _buildStatusText(w.status),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDataLine(Icons.auto_awesome, 'النقاط المستبدلة', '${w.points} نقطة', Colors.orange),
                _buildDataLine(Icons.account_balance, 'البنك المستلم', w.bank, Colors.indigo),
                _buildDataLine(Icons.credit_card, 'رقم الحساب', w.accountNumber, Colors.blueGrey),
                if (isRejected && w.rejectReason != null)
                  _buildDataLine(Icons.info_outline, 'سبب الرفض', w.rejectReason!, Colors.red),
                if (isApproved && w.payout != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDataLine(Icons.payments, 'طريقة الدفع', w.payout!.paymentMethod, Colors.green),
                        _buildDataLine(Icons.confirmation_number, 'رقم المرجع', w.payout!.referenceNumber, Colors.green),
                        _buildDataLine(Icons.calendar_today, 'تاريخ الصرف', w.payout!.paidAt.toString().split(' ')[0], Colors.green),
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
                      onPressed: () => _approveDialog(w),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('اعتماد وصرف', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _rejectDialog(w),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.red.shade400,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
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

  Widget _buildDataLine(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildStatusText(String? status) {
    String text = 'قيد الانتظار';
    Color color = Colors.orange;
    if (status == 'approved') { text = 'تم الصرف'; color = Colors.green; }
    if (status == 'rejected') { text = 'مرفوض'; color = Colors.red; }

    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color));
  }

  Widget _buildStatusEmpty(IconData icon, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.blueGrey.shade100),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.blueGrey.shade300)),
        ],
      ),
    );
  }

  void _approveDialog(WithdrawalRequest w) {
    final methodCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.payments_outlined, color: Colors.blue, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('تأكيد الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يرجى إدخال بيانات التحويل لإتمام العملية بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: methodCtrl,
                decoration: InputDecoration(
                  labelText: 'طريقة الدفع',
                  hintText: 'مثلاً: تحويل بنكي، STC Pay',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: refCtrl,
                decoration: InputDecoration(
                  labelText: 'رقم المرجع',
                  hintText: 'أدخل رقم العملية',
                  prefixIcon: const Icon(Icons.tag_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
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
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text('إلغاء', style: TextStyle(color: Colors.grey[700])),
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
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('تأكيد الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _rejectDialog(WithdrawalRequest w) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('رفض الطلب ❌'),
        content: TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'سبب الرفض')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            Navigator.pop(context);
            await WithdrawalsService.reject(w.id, reasonCtrl.text);
            reload();
          }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('رفض')),
        ],
      ),
    );
  }
}