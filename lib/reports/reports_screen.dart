import 'package:admin_dashboard/reports/services/reports_api.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'models/report_item.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsApiService _apiService = ReportsApiService();
  final Map<int, String> _selectedPeriods = {};
  final Map<int, bool> _loadingStates = {};

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : Colors.blue;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
        appBar: AppBar(
          title: Text(ar ? 'التقارير' : 'Reports'),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. تقرير الاشتراكات الشهرية
            _buildReportCard(
              context,
              titleAr: 'عدد الاشتراكات الشهرية',
              titleEn: 'Monthly Subscriptions Count',
              icon: Icons.subscriptions,
              reportId: 1,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportSubscriptionsReport(ar),
            ),

            const SizedBox(height: 12),

            // 2. تقرير الرسائل المرسلة
            _buildReportCard(
              context,
              titleAr: 'عدد الرسائل المرسلة',
              titleEn: 'Messages Sent Count',
              icon: Icons.message,
              reportId: 2,
              hasPeriod: true,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportMessagesReport(ar),
            ),

            const SizedBox(height: 12),

            // 3. تقرير المجموعات
            _buildReportCard(
              context,
              titleAr: 'عدد المستخدمين في المجموعات',
              titleEn: 'Users in Groups Count',
              icon: Icons.group,
              reportId: 3,
              hasPeriod: true,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportGroupsReport(ar),
            ),

            const SizedBox(height: 12),

            // 4. تقرير العملاء الجدد
            _buildReportCard(
              context,
              titleAr: 'العملاء الجدد المشتركين',
              titleEn: 'New Subscribed Customers',
              icon: Icons.person_add,
              reportId: 4,
              hasPeriod: true,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportNewCustomersReport(ar),
            ),

            const SizedBox(height: 12),

            // 5. تقرير الباقات الأكثر طلباً
            _buildReportCard(
              context,
              titleAr: 'الباقات الأكثر طلباً',
              titleEn: 'Most Popular Packages',
              icon: Icons.trending_up,
              reportId: 5,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportPopularPackagesReport(ar),
            ),

            const SizedBox(height: 12),

            // 6. تقرير المحادثات
            _buildReportCard(
              context,
              titleAr: 'عدد المحادثات مع العملاء شهرياً',
              titleEn: 'Monthly Customer Conversations',
              icon: Icons.chat,
              reportId: 6,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportConversationsReport(ar),
            ),

            const SizedBox(height: 12),

            // 7. تقرير المكافآت
            _buildReportCard(
              context,
              titleAr: 'المكافآت الممنوحة شهرياً',
              titleEn: 'Monthly Rewards Granted',
              icon: Icons.card_giftcard,
              reportId: 7,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportRewardsReport(ar),
            ),

            const SizedBox(height: 12),

            // 8. تقرير المسوقين
            _buildReportCard(
              context,
              titleAr: 'المسوقين والمشرفين',
              titleEn: 'Marketers & Supervisors',
              icon: Icons.supervised_user_circle,
              reportId: 8,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportMarketersReport(ar),
            ),

            const SizedBox(height: 12),

            // 9. تقرير الاقتراحات
            _buildReportCard(
              context,
              titleAr: 'الاقتراحات المستلمة',
              titleEn: 'Suggestions Received',
              icon: Icons.lightbulb,
              reportId: 9,
              hasPeriod: true,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportSuggestionsReport(ar),
            ),

            const SizedBox(height: 12),

            // 10. تقرير الباقات المتاحة
            _buildReportCard(
              context,
              titleAr: 'الباقات المتاحة ومميزاتها',
              titleEn: 'Available Packages & Features',
              icon: Icons.inventory,
              reportId: 10,
              hasPeriod: false,
              primaryColor: primaryColor,
              isDark: isDark,
              ar: ar,
              onExport: () => _exportPackagesDetailsReport(ar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, {
        required String titleAr,
        required String titleEn,
        required IconData icon,
        required int reportId,
        required bool hasPeriod,
        required Color primaryColor,
        required bool isDark,
        required bool ar,
        required VoidCallback onExport,
      }) {
    final selectedPeriod = _selectedPeriods[reportId] ?? 'monthly';
    final isLoading = _loadingStates[reportId] ?? false;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ar ? titleAr : titleEn,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (hasPeriod) ...[
              Text(
                ar ? 'الفترة الزمنية:' : 'Time Period:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPeriodButton(
                      ar ? 'أسبوعي' : 'Weekly',
                      'weekly',
                      reportId,
                      selectedPeriod,
                      primaryColor,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPeriodButton(
                      ar ? 'شهري' : 'Monthly',
                      'monthly',
                      reportId,
                      selectedPeriod,
                      primaryColor,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPeriodButton(
                      ar ? 'سنوي' : 'Yearly',
                      'yearly',
                      reportId,
                      selectedPeriod,
                      primaryColor,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onExport,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  isLoading
                      ? (ar ? 'جاري التحميل...' : 'Loading...')
                      : (ar ? 'تصدير PDF' : 'Export PDF'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
      String label,
      String period,
      int reportId,
      String selectedPeriod,
      Color primaryColor,
      bool isDark,
      ) {
    final isSelected = selectedPeriod == period;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriods[reportId] = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : isDark
              ? Colors.grey[700]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? Colors.grey[300]
                  : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  // دوال التصدير مع الربط بالـ API

  Future<void> _exportSubscriptionsReport(bool ar) async {
    setState(() => _loadingStates[1] = true);
    try {
      final report = await _apiService.getSubscriptionsReport();
      await _generateSubscriptionsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[1] = false);
    }
  }

  Future<void> _exportMessagesReport(bool ar) async {
    final period = _selectedPeriods[2] ?? 'monthly';
    setState(() => _loadingStates[2] = true);
    try {
      final report = await _apiService.getMessagesReport(period);
      await _generateMessagesPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[2] = false);
    }
  }
  Future<void> _exportGroupsReport(bool ar) async {
    final period = _selectedPeriods[3] ?? 'monthly';
    setState(() => _loadingStates[3] = true);
    try {
      final report = await _apiService.getGroupsReport(period);
      await _generateGroupsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[3] = false);
    }
  }
  Future<void> _exportNewCustomersReport(bool ar) async {
    final period = _selectedPeriods[4] ?? 'monthly';
    setState(() => _loadingStates[4] = true);
    try {
      final report = await _apiService.getNewCustomersReport(period);
      await _generateNewCustomersPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[4] = false);
    }
  }
  Future<void> _exportPopularPackagesReport(bool ar) async {
    setState(() => _loadingStates[5] = true);
    try {
      final report = await _apiService.getPopularPackagesReport();
      await _generatePopularPackagesPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[5] = false);
    }
  }
  Future<void> _exportConversationsReport(bool ar) async {
    setState(() => _loadingStates[6] = true);
    try {
      final report = await _apiService.getConversationsReport();
      await _generateConversationsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[6] = false);
    }
  }
  Future<void> _exportRewardsReport(bool ar) async {
    setState(() => _loadingStates[7] = true);
    try {
      final report = await _apiService.getRewardsReport();
      await _generateRewardsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[7] = false);
    }
  }
  Future<void> _exportMarketersReport(bool ar) async {
    setState(() => _loadingStates[8] = true);
    try {
      final report = await _apiService.getMarketersReport();
      await _generateMarketersPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[8] = false);
    }
  }
  Future<void> _exportSuggestionsReport(bool ar) async {
    final period = _selectedPeriods[9] ?? 'monthly';
    setState(() => _loadingStates[9] = true);
    try {
      final report = await _apiService.getSuggestionsReport(period);
      await _generateSuggestionsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[9] = false);
    }
  }
  Future<void> _exportPackagesDetailsReport(bool ar) async {
    setState(() => _loadingStates[10] = true);
    try {
      final report = await _apiService.getPackagesDetailsReport();
      await _generatePackagesDetailsPDF(report, ar);
    } catch (e) {
      _showErrorDialog(ar, e.toString());
    } finally {
      setState(() => _loadingStates[10] = false);
    }
  }
  Future<void> _generateSubscriptionsPDF(
      SubscriptionsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير الاشتراكات الشهرية' : 'Monthly Subscriptions Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'إجمالي الاشتراكات: ${report.totalMonthly}'
                  : 'Total Subscriptions: ${report.totalMonthly}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي الإيرادات: ${report.totalRevenue.toStringAsFixed(2)} ريال'
                  : 'Total Revenue: ${report.totalRevenue.toStringAsFixed(2)} SAR',
              style: const pw.TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateMessagesPDF(
      MessagesReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير الرسائل المرسلة' : 'Messages Sent Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'الفترة: ${_getPeriodLabel(report.period, ar)}'
                  : 'Period: ${_getPeriodLabel(report.period, ar)}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي الرسائل: ${report.total}'
                  : 'Total Messages: ${report.total}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 20),
            ...report.data.map((d) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text('${d.label}: ${d.count}'),
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateGroupsPDF(GroupsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar
                  ? 'تقرير المستخدمين في المجموعات'
                  : 'Users in Groups Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'الفترة: ${_getPeriodLabel(report.period, ar)}'
                  : 'Period: ${_getPeriodLabel(report.period, ar)}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي المستخدمين: ${report.total}'
                  : 'Total Users: ${report.total}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 20),
            ...report.data.map((d) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text('${d.label}: ${d.count}'),
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateNewCustomersPDF(
      NewCustomersReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير العملاء الجدد' : 'New Customers Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'الفترة: ${_getPeriodLabel(report.period, ar)}'
                  : 'Period: ${_getPeriodLabel(report.period, ar)}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي العملاء: ${report.total}'
                  : 'Total Customers: ${report.total}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 20),
            ...report.data.map((d) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                ar
                    ? '${d.label}: ${d.count} (مشتركين: ${d.withSubscription})'
                    : '${d.label}: ${d.count} (Subscribed: ${d.withSubscription})',
              ),
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generatePopularPackagesPDF(
      PopularPackagesReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير الباقات الأكثر طلباً' : 'Popular Packages Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            ...report.packages.map((p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    ar ? p.nameAr : p.nameEn,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    ar
                        ? 'عدد المشتركين: ${p.subscriberCount}'
                        : 'Subscribers: ${p.subscriberCount}',
                  ),
                  pw.Text(
                    ar
                        ? 'الإيرادات: ${p.totalRevenue.toStringAsFixed(2)} ريال'
                        : 'Revenue: ${p.totalRevenue.toStringAsFixed(2)} SAR',
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateConversationsPDF(
      ConversationsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير المحادثات' : 'Conversations Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'إجمالي المحادثات: ${report.totalMonthly}'
                  : 'Total Conversations: ${report.totalMonthly}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar ? 'النشطة: ${report.active}' : 'Active: ${report.active}',
            ),
            pw.Text(
              ar ? 'المغلقة: ${report.closed}' : 'Closed: ${report.closed}',
            ),
            pw.Text(
              ar
                  ? 'متوسط المدة: ${report.avgDurationMinutes.toStringAsFixed(1)} دقيقة'
                  : 'Avg Duration: ${report.avgDurationMinutes.toStringAsFixed(1)} min',
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateRewardsPDF(RewardsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير المكافآت' : 'Rewards Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'إجمالي الممنوح: ${report.totalGranted}'
                  : 'Total Granted: ${report.totalGranted}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              ar
                  ? 'المستخدم: ${report.totalUsed}'
                  : 'Used: ${report.totalUsed}',
            ),
            pw.Text(
              ar
                  ? 'المتبقي: ${report.totalRemaining}'
                  : 'Remaining: ${report.totalRemaining}',
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar ? 'التفاصيل:' : 'Breakdown:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...report.breakdown.map((b) => pw.Text('${b.reason}: ${b.count}')),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateMarketersPDF(
      MarketersReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير المسوقين والمشرفين' : 'Marketers & Supervisors Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'إجمالي المسوقين: ${report.totalMarketers}'
                  : 'Total Marketers: ${report.totalMarketers}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              ar
                  ? 'النشطين: ${report.activeMarketers}'
                  : 'Active: ${report.activeMarketers}',
            ),
            pw.Text(
              ar
                  ? 'المجمدين: ${report.frozenMarketers}'
                  : 'Frozen: ${report.frozenMarketers}',
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي المشرفين: ${report.totalSupervisors}'
                  : 'Total Supervisors: ${report.totalSupervisors}',
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar ? 'أفضل المسوقين:' : 'Top Marketers:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...report.topMarketers.map((m) => pw.Text(
              '${m.name} - ${ar ? 'النقاط' : 'Points'}: ${m.points}',
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generateSuggestionsPDF(
      SuggestionsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              ar ? 'تقرير الاقتراحات' : 'Suggestions Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              ar
                  ? 'الفترة: ${_getPeriodLabel(report.period, ar)}'
                  : 'Period: ${_getPeriodLabel(report.period, ar)}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              ar
                  ? 'إجمالي الاقتراحات: ${report.total}'
                  : 'Total Suggestions: ${report.total}',
            ),
            pw.Text(
              ar
                  ? 'المميزة بنجمة: ${report.starred}'
                  : 'Starred: ${report.starred}',
            ),
            pw.SizedBox(height: 20),
            ...report.data.map((d) => pw.Text('${d.label}: ${d.count}')),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  Future<void> _generatePackagesDetailsPDF(
      PackagesDetailsReportDto report, bool ar) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        textDirection: ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          pw.Text(
            ar ? 'تفاصيل الباقات' : 'Packages Details',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          ...report.packages.map((p) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  ar ? p.nameAr : p.nameEn,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(ar ? p.descriptionAr : p.descriptionEn),
                pw.SizedBox(height: 4),
                pw.Text(
                  ar
                      ? 'السعر: ${p.price.toStringAsFixed(2)} ريال'
                      : 'Price: ${p.price.toStringAsFixed(2)} SAR',
                ),
                pw.Text(
                  ar
                      ? 'المدة: ${p.durationDays} يوم'
                      : 'Duration: ${p.durationDays} days',
                ),
                pw.Text(
                  ar
                      ? 'المشتركين: ${p.subscriberCount}'
                      : 'Subscribers: ${p.subscriberCount}',
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  ar ? 'المميزات:' : 'Features:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ...p.features.map((f) => pw.Text(
                  ar
                      ? '• ${f.featureAr} (${f.limitCount})'
                      : '• ${f.featureEn} (${f.limitCount})',
                )),
                pw.Divider(),
              ],
            ),
          )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  String _getPeriodLabel(String period, bool ar) {
    switch (period.toLowerCase()) {
      case 'weekly':
        return ar ? 'أسبوعي' : 'Weekly';
      case 'monthly':
        return ar ? 'شهري' : 'Monthly';
      case 'yearly':
        return ar ? 'سنوي' : 'Yearly';
      default:
        return period;
    }
  }
  void _showErrorDialog(bool ar, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ar ? 'خطأ' : 'Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ar ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}