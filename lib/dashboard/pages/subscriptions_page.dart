import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Models/SubscriptionModel.dart';
import '../../core/SubscriptionService.dart';
import '../../providers/app_providers.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with SingleTickerProviderStateMixin {
  String selectedStatus = 'all';
  String selectedSubscriptionType = 'all';
  String searchQuery = '';
  int rowsPerPage = 20;
  int currentPage = 0;
  bool loading = true;
  int totalCount = 0;
  List<SubscriptionModel> allSubscriptions = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> subscriptionTypesArabic = ['شهري', 'ربع سنوي', 'نصف سنوي', 'سنوي', 'مجاني'];
  final List<String> subscriptionTypesEnglish = ['Monthly', 'Quarterly', 'Semi-Annual', 'Annual', 'Free'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    final res = await SubscriptionService.fetchSubscriptions(
      status: selectedStatus,
      type: selectedSubscriptionType,
      search: searchQuery,
      page: currentPage + 1,
      pageSize: rowsPerPage,
    );
    totalCount = res['total'];
    allSubscriptions = (res['data'] as List).map((e) => SubscriptionModel.fromJson(e)).toList();
    setState(() => loading = false);
  }

  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subscriptionTypes = isArabic ? subscriptionTypesArabic : subscriptionTypesEnglish;
    final allTypeLabel = isArabic ? 'الكل' : 'All';

    final filtered = allSubscriptions.where((sub) {
      final matchesStatus = selectedStatus == 'all' || sub.status == selectedStatus;
      final matchesSearch = sub.user!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedSubscriptionType == 'all' || sub.type == selectedSubscriptionType;
      return matchesStatus && matchesSearch && matchesType;
    }).toList();

    final totalPages = (filtered.length / rowsPerPage).ceil();
    final paginated = filtered.skip(currentPage * rowsPerPage).take(rowsPerPage).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isArabic, isDark),
              const SizedBox(height: 32),
              _buildStatsCards(filtered, isArabic, isDark),
              const SizedBox(height: 32),
              _buildFiltersSection(isArabic, isDark, subscriptionTypes, allTypeLabel),
              const SizedBox(height: 32),
              _buildDataTable(paginated, filtered, totalPages, isArabic, isDark, subscriptionTypes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.subscriptions_outlined, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'إدارة الاشتراكات' : 'Subscriptions Management',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'إدارة ومتابعة جميع الاشتراكات والمستخدمين'
                      : 'Manage and monitor all subscriptions and users',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${allSubscriptions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<SubscriptionModel> filtered, bool isArabic, bool isDark) {
    final active = filtered.where((s) => s.status == 'active').length;
    final expired = filtered.where((s) => s.status == 'expired').length;
    final frozen = filtered.where((s) => s.status == 'frozen').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات نشطة' : 'Active Subscriptions',
              active.toString(),
              Icons.verified,
              const Color(0xFF4CAF50),
              isDark,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات منتهية' : 'Expired Subscriptions',
              expired.toString(),
              Icons.event_busy,
              const Color(0xFFE53935),
              isDark,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات مجمدة' : 'Frozen Subscriptions',
              frozen.toString(),
              Icons.pause_circle_outline,
              const Color(0xFFFF6F00),
              isDark,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'إجمالي الاشتراكات' : 'Total Subscriptions',
              filtered.length.toString(),
              Icons.analytics,
              const Color(0xFF1976D2),
              isDark,
            )),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Icon(Icons.trending_up, color: color.withOpacity(0.5), size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(bool isArabic, bool isDark, List<String> subscriptionTypes, String allTypeLabel) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE3F2FD),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.filter_list, color: Color(0xFF1976D2), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                isArabic ? 'البحث والتصفية' : 'Search & Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: isArabic ? 'ابحث باسم المستخدم أو البريد الإلكتروني' : 'Search by username or email',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2), size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        currentPage = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),

                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterChip(isArabic ? 'جميع الحالات' : 'All Status', 'all', const Color(0xFF1976D2), isArabic, isDark),
              _buildFilterChip(isArabic ? '✓ نشط' : '✓ Active', 'active', const Color(0xFF4CAF50), isArabic, isDark),
              _buildFilterChip(isArabic ? '✕ منتهي' : '✕ Expired', 'expired', const Color(0xFFE53935), isArabic, isDark),
              _buildFilterChip(isArabic ? '⊗ مجمد' : '⊗ Frozen', 'frozen', const Color(0xFFFF6F00), isArabic, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color, bool isArabic, bool isDark) {
    final selected = selectedStatus == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = value;
          currentPage = 0;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: selected ? null : (isDark ? const Color(0xFF0F172A) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<SubscriptionModel> paginated, List<SubscriptionModel> filtered,
      int totalPages, bool isArabic, bool isDark, List<String> subscriptionTypes)
  {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE3F2FD),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.table_chart, color: Color(0xFF1976D2), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isArabic ? 'قائمة الاشتراكات' : 'Subscriptions List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} ${isArabic ? 'نتيجة' : 'Results'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          if (loading)
            Container(
              height: 400,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64,
                ),
                child: DataTable(
                  columnSpacing: 40,
                  horizontalMargin: 28,
                  headingRowHeight: 60,
                  dataRowHeight: 72,
                  headingRowColor: MaterialStateProperty.all(
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF),
                  ),
                  columns: [
                    DataColumn(label: _buildColumnHeader(isArabic ? 'المستخدم' : 'User', Icons.person_outline)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'البريد الإلكتروني' : 'Email', Icons.email_outlined)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'نوع الاشتراك' : 'Type', Icons.card_membership)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'تاريخ البداية' : 'Start Date', Icons.calendar_today)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'تاريخ النهاية' : 'End Date', Icons.event)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'المتبقي' : 'Remining', Icons.account_balance_wallet)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'الحالة' : 'Status', Icons.info_outline)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'الإجراءات' : 'Actions', Icons.settings)),
                  ],
                  rows: paginated.map((sub) => _buildDataRow(sub, isArabic, subscriptionTypes, isDark)).toList(),
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1),
          _buildPagination(totalPages, isArabic, isDark),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1976D2)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(SubscriptionModel sub, bool isArabic, List<String> subscriptionTypes, bool isDark) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (sub.status) {
      case 'active':
        statusColor = const Color(0xFF4CAF50);
        statusText = isArabic ? 'نشط' : 'Active';
        statusIcon = Icons.check_circle;
        break;
      case 'expired':
        statusColor = const Color(0xFFE53935);
        statusText = isArabic ? 'منتهي' : 'Expired';
        statusIcon = Icons.cancel;
        break;
      case 'frozen':
        statusColor = const Color(0xFFFF6F00);
        statusText = isArabic ? 'مجمد' : 'Frozen';
        statusIcon = Icons.pause_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = isArabic ? 'غير معروف' : 'Unknown';
        statusIcon = Icons.help_outline;
    }

    return DataRow(
      color: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return isDark
              ? const Color(0xFF1976D2).withOpacity(0.05)
              : const Color(0xFFE3F2FD).withOpacity(0.5);
        }
        return null;
      }),
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1976D2).withOpacity(0.8),
                      const Color(0xFF42A5F5).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    sub.user![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                sub.user!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(sub.email, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1976D2).withOpacity(0.1),
                  const Color(0xFF42A5F5).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3), width: 1.5),
            ),
            child: Text(
              sub.type!,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.login, size: 16, color: Color(0xFF4CAF50)),
              const SizedBox(width: 6),
              Text(sub.startDate!, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.logout, size: 16, color: Color(0xFFE53935)),
              const SizedBox(width: 6),
              Text(sub.endDate!, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFFE53935)),
              const SizedBox(width: 6),
              Text(sub.RemainingCount!.toString(), style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                Icons.edit_outlined,
                const Color(0xFF1976D2),
                isArabic ? 'تعديل' : 'Edit',
                    () => _showEditDialog(sub, isArabic),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.refresh,
                const Color(0xFF4CAF50),
                isArabic ? 'تجديد' : 'Renew',
                    () => renewSubscription(sub),
              ),
              const SizedBox(width: 8),
              buildFreezeButton(sub, isArabic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
  Widget buildFreezeButton(SubscriptionModel sub, bool isArabic) {
    final isFrozen = sub.status == 'frozen';

    return _buildActionButton(
      isFrozen ? Icons.lock_open : Icons.block,
      isFrozen ? Colors.green : const Color(0xFFE53935),
      isFrozen
          ? (isArabic ? 'فك التجميد' : 'Unfreeze')
          : (isArabic ? 'تجميد' : 'Freeze'),
          () async {
        try {
          if (isFrozen) {
            await SubscriptionService.unfreeze(sub.id);
            setState(() => sub.status = 'active');
          } else {
            await SubscriptionService.freeze(sub.id);
            setState(() => sub.status = 'frozen');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'حدث خطأ أثناء تنفيذ العملية'
                    : 'Operation failed',
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPagination(int totalPages, bool isArabic, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
            icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, size: 20),
            label: Text(
              isArabic ? 'السابق' : 'Previous',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${isArabic ? 'صفحة' : 'Page'} ${currentPage + 1} ${isArabic ? 'من' : 'of'} $totalPages',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
            icon: Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 20),
            label: Text(
              isArabic ? 'التالي' : 'Next',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> renewSubscription(SubscriptionModel subscription) async {
    try {
      setState(() => loading = true);

      await SubscriptionService.renew(subscription.id);

      currentPage = 0;
      await loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تجديد الاشتراك بنجاح'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }

    }  catch (e) {
  print('Renew error: $e');

  if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('خطأ: $e'),
  backgroundColor: Colors.red,
  ),
  );
  }
  }
  finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showEditDialog(SubscriptionModel subscription, bool isArabic) {
    DateTime startDate = DateTime.parse(subscription.startDate!);
    DateTime endDate = DateTime.parse(subscription.endDate!);

    int giftDays = 0;
    int giftGroups = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isArabic ? 'إدارة الاشتراك' : 'Manage Subscription'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// ================== DATES ==================
                    ListTile(
                      leading: const Icon(Icons.login, color: Color(0xFF4CAF50)),
                      title: Text(isArabic ? 'تاريخ البداية' : 'Start Date'),
                      subtitle: Text(dateFormat.format(startDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                      title: Text(isArabic ? 'تاريخ النهاية' : 'End Date'),
                      subtitle: Text(dateFormat.format(endDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                    ),

                    const Divider(),

                    /// ================== GIFT DAYS ==================
                    ListTile(
                      leading: const Icon(Icons.card_giftcard, color: Colors.blue),
                      title: Text(isArabic ? 'أيام هدية' : 'Gift Days'),
                      subtitle: Text(isArabic
                          ? 'تضاف إلى نهاية الاشتراك'
                          : 'Added to subscription end date'),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          onChanged: (val) {
                            setDialogState(() {
                              giftDays = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ),

                    /// ================== GIFT GROUPS ==================
                    ListTile(
                      leading: const Icon(Icons.group_add, color: Colors.green),
                      title: Text(isArabic ? 'مجموعات هدية' : 'Gift Groups'),
                      subtitle: Text(isArabic
                          ? 'تضاف كباقة إضافية'
                          : 'Extra groups as gift'),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          onChanged: (val) {
                            setDialogState(() {
                              giftGroups = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {

                    /// 🟢 1) تحديث التواريخ
                    if (giftDays > 0) {
                      endDate = endDate.add(Duration(days: giftDays));
                    }

                    await SubscriptionService.updateSubscriptionDates(
                      subscription.id,
                      startDate,
                      endDate,
                    );

                    /// 🟢 2) إضافة مجموعات هدية
                    if (giftGroups > 0) {
                      await SubscriptionService.addGiftGroups(
                        subscriptionId: subscription.id,
                        groupsCount: giftGroups,
                      );
                    }

                    Navigator.pop(context);
                    loadData();
                  },
                  child: Text(isArabic ? 'حفظ' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}