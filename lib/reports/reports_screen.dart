// lib/screens/reports_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'services/reports_api.dart';
import 'dart:html' as html;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  final ReportsApiService _apiService = ReportsApiService();
  final Map<int, String> _selectedPeriods = {};
  final Map<int, bool> _loadingStates = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ألوان الوضع الفاتح (أزرق)
    final lightPrimaryColor = const Color(0xFF1976D2);
    final lightSecondaryColor = const Color(0xFF42A5F5);
    final lightAccentColor = const Color(0xFF2196F3);

    // ألوان الوضع الداكن (أخضر)
    final darkPrimaryColor = const Color(0xFF00C853);
    final darkSecondaryColor = const Color(0xFF69F0AE);
    final darkAccentColor = const Color(0xFF00E676);

    final primaryColor = isDark ? darkPrimaryColor : lightPrimaryColor;
    final secondaryColor = isDark ? darkSecondaryColor : lightSecondaryColor;
    final accentColor = isDark ? darkAccentColor : lightAccentColor;

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section - كارد أعرض مع تدرجات لونية
                Container(
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        accentColor,
                        secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.assessment_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                      ).createShader(bounds),
                                      child: Text(
                                        ar ? 'التقارير والإحصائيات' : 'Reports & Analytics',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      ar ? 'قم بتصدير وتحليل جميع تقارير البرنامج بصيغة PDF' : 'Export and analyze all system reports in PDF',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider مع تدرج لوني
                        Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.1),
                                secondaryColor.withOpacity(0.3),
                                primaryColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),

                        // Stats Section
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context: context,
                                title: ar ? 'إجمالي التقارير' : 'Total Reports',
                                value: '10',
                                icon: Icons.folder_copy_rounded,
                                color: primaryColor,
                                isDark: isDark,
                              ),
                              _buildStatItem(
                                context: context,
                                title: ar ? 'تقارير متاحة' : 'Available',
                                value: '10',
                                icon: Icons.check_circle_rounded,
                                color: accentColor,
                                isDark: isDark,
                              ),
                              _buildStatItem(
                                context: context,
                                title: ar ? 'تنسيق PDF' : 'PDF Format',
                                value: ar ? 'جميع التقارير' : 'All Reports',
                                icon: Icons.picture_as_pdf_rounded,
                                color: const Color(0xFFF44336),
                                isDark: isDark,
                              ),
                              _buildStatItem(
                                context: context,
                                title: ar ? 'محدث تلقائياً' : 'Auto Updated',
                                value: ar ? 'يومياً' : 'Daily',
                                icon: Icons.update_rounded,
                                color: const Color(0xFFFF9800),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Reports Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1600 ? 3 : (constraints.maxWidth > 1100 ? 2 : 1);

                    return GridView.count(
                      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: (constraints.maxWidth / crossAxisCount) / 100,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _buildAllReports(context, ar, isDark, primaryColor, secondaryColor, cardColor),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget لبناء عنصر الإحصائية في الـ Header
  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // باقي الكود كما هو دون تغيير...
  List<Widget> _buildAllReports(BuildContext context, bool ar, bool isDark, Color pColor, Color sColor, Color cardColor) {
    return [
      _buildReportCard(context, titleAr: 'عدد الاشتراكات الشهرية', titleEn: 'Monthly Subscriptions', descriptionAr: 'تقرير شامل لجميع الاشتراكات النشطة', descriptionEn: 'Comprehensive active subscriptions', icon: Icons.subscriptions_rounded, reportId: 1, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportSubscriptionsReport(ar)),
      _buildReportCard(context, titleAr: 'عدد الرسائل المرسلة', titleEn: 'Messages Sent Count', descriptionAr: 'إحصائيات الرسائل حسب الفترة', descriptionEn: 'Message statistics by period', icon: Icons.message_rounded, reportId: 2, hasPeriod: true, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportMessagesReport(ar)),
      _buildReportCard(context, titleAr: 'المستخدمين في المجموعات', titleEn: 'Users in Groups', descriptionAr: 'تفاصيل المجموعات النشطة', descriptionEn: 'Active groups details', icon: Icons.groups_rounded, reportId: 3, hasPeriod: true, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportGroupsReport(ar)),
      _buildReportCard(context, titleAr: 'العملاء الجدد', titleEn: 'New Customers', descriptionAr: 'تقرير العملاء المنضمين حديثاً', descriptionEn: 'Recently joined customers', icon: Icons.person_add_rounded, reportId: 4, hasPeriod: true, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportNewCustomersReport(ar)),
      _buildReportCard(context, titleAr: 'الباقات الأكثر طلباً', titleEn: 'Most Popular Packages', descriptionAr: 'تحليل الباقات الأعلى مبيعاً', descriptionEn: 'Top selling packages analysis', icon: Icons.trending_up_rounded, reportId: 5, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportPopularPackagesReport(ar)),
      _buildReportCard(context, titleAr: 'المحادثات مع العملاء', titleEn: 'Customer Conversations', descriptionAr: 'إحصائيات المحادثات الشهرية', descriptionEn: 'Monthly conversation stats', icon: Icons.chat_bubble_rounded, reportId: 6, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportConversationsReport(ar)),
      _buildReportCard(context, titleAr: 'المكافآت الممنوحة', titleEn: 'Rewards Granted', descriptionAr: 'تفاصيل المكافآت والحوافز', descriptionEn: 'Rewards and incentives details', icon: Icons.card_giftcard_rounded, reportId: 7, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportRewardsReport(ar)),
      _buildReportCard(context, titleAr: 'المسوقين والمشرفين', titleEn: 'Marketers & Supervisors', descriptionAr: 'بيانات فريق التسويق', descriptionEn: 'Marketing team data', icon: Icons.supervised_user_circle_rounded, reportId: 8, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportMarketersReport(ar)),
      _buildReportCard(context, titleAr: 'الاقتراحات المستلمة', titleEn: 'Suggestions Received', descriptionAr: 'تقييم وتحليل الاقتراحات', descriptionEn: 'Suggestions evaluation', icon: Icons.lightbulb_rounded, reportId: 9, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportSuggestionsReport(ar)),
      _buildReportCard(context, titleAr: 'الباقات ومميزاتها', titleEn: 'Packages & Features', descriptionAr: 'دليل شامل للباقات المتاحة', descriptionEn: 'Complete packages guide', icon: Icons.inventory_2_rounded, reportId: 10, hasPeriod: false, primaryColor: pColor, secondaryColor: sColor, isDark: isDark, ar: ar, cardColor: cardColor, onExport: () => _exportPackagesDetailsReport(ar)),
    ];
  }

  Widget _buildReportCard(BuildContext context, {required String titleAr, required String titleEn, required String descriptionAr, required String descriptionEn, required IconData icon, required int reportId, required bool hasPeriod, required Color primaryColor, required Color secondaryColor, required bool isDark, required bool ar, required Color cardColor, required VoidCallback onExport}) {
    final selectedPeriod = _selectedPeriods[reportId] ?? 'monthly';
    final isLoading = _loadingStates[reportId] ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 1),
          boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(ar ? 0 : 16), right: Radius.circular(ar ? 16 : 0)),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ar ? titleAr : titleEn, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (hasPeriod)
                      _buildWebPeriodPicker(reportId, selectedPeriod, primaryColor, ar, isDark)
                    else
                      Text(ar ? descriptionAr : descriptionEn, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(onPressed: onExport, icon: Icon(Icons.download_for_offline_rounded, color: primaryColor, size: 32)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPeriodPicker(int id, String selected, Color color, bool ar, bool isDark) {
    final options = [{'id': 'weekly', 'label': ar ? 'أسبوع' : 'W'}, {'id': 'monthly', 'label': ar ? 'شهر' : 'M'}, {'id': 'yearly', 'label': ar ? 'سنة' : 'Y'}];
    return Row(
      children: options.map((opt) {
        bool isS = selected == opt['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedPeriods[id] = opt['id']!),
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: isS ? color : (isDark ? Colors.white10 : Colors.grey[100]), borderRadius: BorderRadius.circular(6)),
            child: Text(opt['label']!, style: TextStyle(fontSize: 10, color: isS ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _downloadPdf(Uint8List bytes, String fileName, bool ar) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)..setAttribute("download", fileName)..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    }
  }

  void _showErrorSnackBar(bool ar, String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'حدث خطأ: $error' : 'Error: $error')));
  }

  // دوال الـ Export المتبقية...
  Future<void> _exportSubscriptionsReport(bool ar) async {
    setState(() => _loadingStates[1] = true);
    try {
      final pdfBytes = await _apiService.getSubscriptionsPdf();
      await _downloadPdf(pdfBytes, 'Subscriptions_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[1] = false); }
  }

  Future<void> _exportMessagesReport(bool ar) async {
    final period = _selectedPeriods[2] ?? 'monthly';
    setState(() => _loadingStates[2] = true);
    try {
      final pdfBytes = await _apiService.getMessagesPdf(period);
      await _downloadPdf(pdfBytes, 'Messages_Report_${period}_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[2] = false); }
  }

  Future<void> _exportGroupsReport(bool ar) async {
    final period = _selectedPeriods[3] ?? 'monthly';
    setState(() => _loadingStates[3] = true);
    try {
      final pdfBytes = await _apiService.getGroupsPdf(period);
      await _downloadPdf(pdfBytes, 'Groups_Report_${period}_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[3] = false); }
  }

  Future<void> _exportNewCustomersReport(bool ar) async {
    final period = _selectedPeriods[4] ?? 'monthly';
    setState(() => _loadingStates[4] = true);
    try {
      final pdfBytes = await _apiService.getNewCustomersPdf(period);
      await _downloadPdf(pdfBytes, 'New_Customers_Report_${period}_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[4] = false); }
  }

  Future<void> _exportPopularPackagesReport(bool ar) async {
    setState(() => _loadingStates[5] = true);
    try {
      final pdfBytes = await _apiService.getPopularPackagesPdf();
      await _downloadPdf(pdfBytes, 'Popular_Packages_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[5] = false); }
  }

  Future<void> _exportConversationsReport(bool ar) async {
    setState(() => _loadingStates[6] = true);
    try {
      final pdfBytes = await _apiService.getConversationsPdf();
      await _downloadPdf(pdfBytes, 'Conversations_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[6] = false); }
  }

  Future<void> _exportRewardsReport(bool ar) async {
    setState(() => _loadingStates[7] = true);
    try {
      final pdfBytes = await _apiService.getRewardsPdf();
      await _downloadPdf(pdfBytes, 'Rewards_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[7] = false); }
  }

  Future<void> _exportMarketersReport(bool ar) async {
    setState(() => _loadingStates[8] = true);
    try {
      final pdfBytes = await _apiService.getMarketersPdf();
      await _downloadPdf(pdfBytes, 'Marketers_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[8] = false); }
  }

  Future<void> _exportSuggestionsReport(bool ar) async {
    final period = _selectedPeriods[9] ?? 'monthly';
    setState(() => _loadingStates[9] = true);
    try {
      final pdfBytes = await _apiService.getSuggestionsPdf(period);
      await _downloadPdf(pdfBytes, 'Suggestions_Report_${period}_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[9] = false); }
  }

  Future<void> _exportPackagesDetailsReport(bool ar) async {
    setState(() => _loadingStates[10] = true);
    try {
      final pdfBytes = await _apiService.getPackagesDetailsPdf();
      await _downloadPdf(pdfBytes, 'Packages_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', ar);
    } catch (e) { _showErrorSnackBar(ar, e.toString()); } finally { setState(() => _loadingStates[10] = false); }
  }
}