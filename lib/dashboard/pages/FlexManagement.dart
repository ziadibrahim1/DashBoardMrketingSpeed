import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;

import '../../Models/PackageEditor.dart';
import '../../Models/packageNotificationModal.dart';
import '../../core/app_config.dart';
import '../../services/api_service.dart';
import 'Package.dart';

class PackagesPage extends StatefulWidget {
  final bool isArabic;

  const PackagesPage({super.key, required this.isArabic});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> with TickerProviderStateMixin {
  late List<Package> _packages;
  late String selectedFilter;
  late String selectedSort;
  late bool showArchived;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _packages = [];
    selectedFilter = widget.isArabic ? 'الكل' : 'All';
    selectedSort = 'id';
    showArchived = false;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _loadPackages();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  int generateUniqueId() {
    final rand = Random();
    int newId;
    do {
      newId = 100000 + rand.nextInt(900000);
    } while (_packages.any((p) => p.id == newId));
    return newId;
  }

  Future<void> _loadPackages() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}admin/packages'),
    );

    final List data = jsonDecode(res.body);

    setState(() {
      _packages = data.map((e) => Package.fromJson(e, widget.isArabic)).toList();
    });

    _fadeController.forward();
  }

  int get totalSubscribers => _packages.fold(0, (sum, p) => sum + p.subscribers);

  List<Package> get filteredPackages {
    List<Package> list = [..._packages];

    if (!showArchived) {
      list = list.where((p) => !p.isArchived).toList();
    }

    if (selectedFilter == (widget.isArabic ? 'باقات مخفضة' : 'Discounted Packages')) {
      list = list.where((p) => p.discount != null && p.discount! > 0).toList();
    } else if (selectedFilter == (widget.isArabic ? 'باقات بها مشتركين' : 'Packages with Subscribers')) {
      list = list.where((p) => p.subscribers > 0).toList();
    } else if (selectedFilter == (widget.isArabic ? 'مجدولة' : 'Scheduled')) {
      list = list.where((p) => p.isScheduledFuture).toList();
    }

    switch (selectedSort) {
      case 'price':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'duration':
        list.sort((a, b) => a.durationDays.compareTo(b.durationDays));
        break;
      case 'subscribers':
        list.sort((a, b) => a.subscribers.compareTo(b.subscribers));
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }
    return list;
  }

  int getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  void _openPackageEditor({Package? existing, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PackageEditor(
          existing: existing,
          generateId: generateUniqueId,
          onSave: (pkg) {
            setState(() {
              if (index != null) {
                _packages[index] = pkg;
                pkg.addLog(widget.isArabic ? 'تم تعديل الباقة' : 'Package edited');
              } else {
                _packages.add(pkg);
                pkg.addLog(widget.isArabic ? 'تم إنشاء الباقة' : 'Package created');
              }
            });
          },
          isArabic: widget.isArabic,
        );
      },
    );
  }

  Future<void> _toggleArchiveById(int packageId) async {
    try {
      final pkg = _packages.firstWhere((p) => p.id == packageId);
      final newValue = await ApiService.toggleArchive(pkg.id);

      setState(() {
        pkg.isArchived = newValue;
        pkg.addLog(
          newValue
              ? (widget.isArabic ? 'أرشفة الباقة' : 'Package archived')
              : (widget.isArabic ? 'استرجاع الباقة' : 'Package restored'),
        );
      });

      await _loadPackages();

      _showSnackBar(
        newValue
            ? (widget.isArabic ? 'تمت الأرشفة بنجاح' : 'Archived successfully')
            : (widget.isArabic ? 'تم الاسترجاع بنجاح' : 'Restored successfully'),
        Colors.green,
        Icons.check_circle_rounded,
      );
    } catch (e) {
      _showSnackBar(
        widget.isArabic ? 'فشل تنفيذ العملية' : 'Operation failed',
        Colors.red,
        Icons.error_rounded,
      );
    }
  }

  Future<void> _toggleStatus(int index) async {
    final pkg = _packages.firstWhere((p) => p.id == index);
    try {
      final res = await http.patch(
        Uri.parse('${AppConfig.baseUrl}admin/packages/${pkg.id}/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final newStatus = res.body.replaceAll('"', '');
        setState(() {
          pkg.status = newStatus == 'active' ? PackageStatus.active : PackageStatus.paused;
          pkg.addLog(widget.isArabic
              ? 'تغيير الحالة إلى ${pkg.status == PackageStatus.active ? 'مفعلة' : 'معطله'}'
              : 'Status changed to ${pkg.status == PackageStatus.active ? 'Active' : 'Paused'}');
        });

        _showSnackBar(
          widget.isArabic ? 'تم تغيير الحالة بنجاح' : 'Status changed successfully',
          Colors.blue,
          Icons.toggle_on_rounded,
        );
      } else {
        _showSnackBar(
          widget.isArabic ? 'فشل تغيير الحالة' : 'Failed to update status',
          Colors.red,
          Icons.error_rounded,
        );
      }
    } catch (e) {
      _showSnackBar(
        widget.isArabic ? 'خطأ في الاتصال بالسيرفر' : 'Server error',
        Colors.red,
        Icons.error_rounded,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openNotificationModal(Package package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        return NotificationModal(
          package: package,
          isArabic: widget.isArabic,
          onSent: (method, title, content, scheduled) {
            setState(() {
              package.addLog(
                '${widget.isArabic ? 'تم إرسال إشعار بعنوان' : 'Notification sent titled'} "$title" ${widget.isArabic ? 'عبر' : 'via'} $method${scheduled != null ? (widget.isArabic ? ' (مجدول لـ ${DateFormat('yyyy/MM/dd').format(scheduled)})' : ' (Scheduled for ${DateFormat('yyyy/MM/dd').format(scheduled)})') : ''}',
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = getCrossAxisCount(width);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterOptions = widget.isArabic
        ? ['الكل', 'باقات مخفضة', 'باقات بها مشتركين', 'مجدولة']
        : ['All', 'Discounted Packages', 'Packages with Subscribers', 'Scheduled'];

    final sortOptions = widget.isArabic
        ? {
      'id': 'معرف',
      'price': 'السعر',
      'duration': 'مدة',
      'subscribers': 'مشتركين',
    }
        : {
      'id': 'ID',
      'price': 'Price',
      'duration': 'Duration',
      'subscribers': 'Subscribers',
    };

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                const Color(0xFF0F2027),
                const Color(0xFF203A43),
                const Color(0xFF2C5364),
              ]
                  : [
                Colors.blue.shade50,
                Colors.white,
                Colors.cyan.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildModernHeader(isDark, filterOptions, sortOptions),
                    const SizedBox(height: 24),

                    _buildStatsCards(isDark),
                    const SizedBox(height: 24),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 420,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: filteredPackages.length,
                      itemBuilder: (context, i) {
                        final p = filteredPackages[i];
                        return PackageCardAdvanced(
                          package: p,
                          onEdit: () => _openPackageEditor(existing: p, index: i),
                          onArchive: () => _toggleArchiveById(p.id),
                          onToggleStatus: () => _toggleStatus(p.id),
                          onNotify: () => _openNotificationModal(p),
                          onViewLogs: () => showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => LogsViewer(package: p, isArabic: widget.isArabic),
                          ),
                          isArabic: widget.isArabic,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark, List<String> filterOptions, Map<String, String> sortOptions) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade900, Colors.cyan.shade900]
              : [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'إدارة الباقات' : 'Packages Management',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isArabic ? 'تحكم كامل بجميع الباقات' : 'Full control over all packages',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _openPackageEditor(),
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  label: Text(
                    widget.isArabic ? 'إضافة باقة' : 'Add Package',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(filterOptions, isDark),
                ),
                const SizedBox(width: 12),
                _buildSortButton(sortOptions, isDark),
                const SizedBox(width: 20),
                _buildArchivedToggle(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(List<String> options, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedFilter,
        dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
        underline: const SizedBox(),
        icon:  Icon(Icons.arrow_drop_down_rounded, color: Colors.blue.shade900),
        style:  TextStyle(color: Colors.blue.shade900, fontSize: 14, fontWeight: FontWeight.w600),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) {
          if (v != null) setState(() => selectedFilter = v);
        },
      ),
    );
  }

  Widget _buildSortButton(Map<String, String> options, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.sort_rounded, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        onSelected: (val) {
          setState(() => selectedSort = val);
        },
        itemBuilder: (_) => options.entries
            .map((e) => PopupMenuItem(
          value: e.key,
          child: Row(
            children: [
              Icon(
                _getSortIcon(e.key),
                size: 20,
                color: isDark ? Colors.white70 : Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Text(
                e.value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  IconData _getSortIcon(String key) {
    switch (key) {
      case 'price':
        return Icons.attach_money_rounded;
      case 'duration':
        return Icons.schedule_rounded;
      case 'subscribers':
        return Icons.people_rounded;
      default:
        return Icons.tag_rounded;
    }
  }

  Widget _buildArchivedToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            showArchived ? Icons.inventory_rounded : Icons.inventory_2_outlined,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isArabic ? 'المؤرشفة' : 'Archived',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: showArchived,
            onChanged: (val) => setState(() => showArchived = val),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.white,
            activeTrackColor: Colors.green.shade300,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: StatCardGradient(
            title: widget.isArabic ? 'عدد الباقات' : 'Number of Packages',
            value: _packages.where((p) => !p.isArchived).length.toString(),
            icon: Icons.inventory_2_rounded,
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blue.shade800, Colors.blue.shade900]
                  : [Colors.blue.shade400, Colors.blue.shade600],
            ),
            isArabic: widget.isArabic,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCardGradient(
            title: widget.isArabic ? 'إجمالي المشتركين' : 'Total Subscribers',
            value: totalSubscribers.toString(),
            icon: Icons.people_rounded,
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blue.shade300, Colors.blue.shade600]
                  : [Colors.blue.shade100, Colors.blue.shade300],
            ),
            isArabic: widget.isArabic,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCardGradient(
            title: widget.isArabic ? 'باقات مجدولة مستقبلية' : 'Scheduled Packages',
            value: _packages.where((p) => p.isScheduledFuture).length.toString(),
            icon: Icons.schedule_rounded,
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blue.shade800, Colors.blue.shade900]
                  : [Colors.blue.shade400, Colors.blue.shade800],
            ),
            isArabic: widget.isArabic,
          ),
        ),
      ],
    );
  }
}

class StatCardGradient extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final bool isArabic;

  const StatCardGradient({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PackageCardAdvanced extends StatefulWidget {
  final Package package;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onToggleStatus;
  final VoidCallback onNotify;
  final VoidCallback onViewLogs;
  final bool isArabic;

  const PackageCardAdvanced({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onArchive,
    required this.onToggleStatus,
    required this.onNotify,
    required this.onViewLogs,
    required this.isArabic,
  });

  @override
  State<PackageCardAdvanced> createState() => _PackageCardAdvancedState();
}

class _PackageCardAdvancedState extends State<PackageCardAdvanced> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.2),
                      blurRadius: _isHovered ? 25 : 15,
                      offset: Offset(0, _isHovered ? 12 : 8),
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                          const Color(0xFF1E3A8A),
                          const Color(0xFF1E40AF),
                          const Color(0xFF3B82F6),
                        ]
                            : [
                          Colors.white,
                          Colors.blue.shade50,
                          Colors.cyan.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    // هنا حولنا Column إلى Scrollable
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.package.shouldShowInactiveBanner)
                              _buildInactiveBanner(),
                            _buildHeader(isDark),
                            const SizedBox(height: 16),
                            _buildInfoTags(isDark),
                            const SizedBox(height: 5),
                            _buildFeatures(isDark),
                            _buildActions(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )

              ),
              if (widget.package.isArchived)
                _buildArchivedBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_rounded, size: 20, color: Colors.orange.shade900),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isArabic
                  ? 'لا يوجد مشتركين في هذه الباقة منذ أكثر من شهر'
                  : 'No subscribers in this package for over a month',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.package.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${widget.package.id}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.package.status == PackageStatus.active
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.grey.shade500, Colors.grey.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.package.status == PackageStatus.active
                    ? Colors.green.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.package.status == PackageStatus.active
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.package.status == PackageStatus.active
                    ? (widget.isArabic ? 'مفعلة' : 'Active')
                    : (widget.isArabic ? 'معطله' : 'Paused'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTags(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          Icons.payments_rounded,
          '${widget.package.price.toStringAsFixed(2)} ${widget.isArabic ? 'ر.س' : 'SAR'}',
          isDark ? Colors.blue.shade700 : Colors.blue.shade600,
          isDark,
        ),
        _buildInfoChip(
          Icons.schedule_rounded,
          '${widget.package.durationDays} ${widget.isArabic ? 'يوم' : 'days'}',
          isDark ? Colors.cyan.shade700 : Colors.cyan.shade600,
          isDark,
        ),
        _buildInfoChip(
          widget.package.CategoryId == 1 ? Icons.star_rounded : Icons.workspace_premium_rounded,
          widget.package.CategoryId == 1
              ? (widget.isArabic ? 'أساسية' : 'Basic')
              : (widget.isArabic ? 'إضافية' : 'Extra'),
          widget.package.CategoryId == 1 ? Colors.green.shade600 : Colors.orange.shade600,
          isDark,
        ),
        _buildInfoChip(
          widget.package.CategoryId == 1 ? Icons.star_rounded : Icons.workspace_premium_rounded,
          (widget.isArabic ? ' المشتركين : ${widget.package.subscribers} ' : 'Subscribers ${widget.package.subscribers}') ,
          widget.package.CategoryId == 1 ? Colors.green.shade600 : Colors.orange.shade600,
          isDark,
        ),
        if (widget.package.discount != null)
          _buildInfoChip(
            Icons.local_offer_rounded,
            '${widget.package.discount!.toStringAsFixed(0)}% ${widget.isArabic ? 'خصم' : 'OFF'}',
            Colors.red.shade600,
            isDark,
          ),
        if (widget.package.isScheduledFuture)
          _buildInfoChip(
            Icons.event_rounded,
            DateFormat('MMM dd').format(widget.package.startDate!),
            Colors.purple.shade600,
            isDark,
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.3 : 0.2),
            color.withOpacity(isDark ? 0.2 : 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isArabic ? 'المميزات' : 'Features',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.package.features.map((f) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${f.feature} (${f.limitCount})',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.edit_rounded,
            widget.isArabic ? 'تعديل' : 'Edit',
            Colors.blue,
            widget.onEdit,
          ),
          _buildActionButton(
            widget.package.isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
            widget.package.isArchived
                ? (widget.isArabic ? 'استرجاع' : 'Restore')
                : (widget.isArabic ? 'أرشفة' : 'Archive'),
            Colors.orange,
            widget.onArchive,
          ),
          _buildActionButton(
            widget.package.status == PackageStatus.active
                ? Icons.pause_circle_rounded
                : Icons.play_circle_rounded,
            widget.package.status == PackageStatus.active
                ? (widget.isArabic ? 'إيقاف' : 'Pause')
                : (widget.isArabic ? 'تفعيل' : 'Activate'),
            Colors.purple,
            widget.onToggleStatus,
          ),
          _buildActionButton(
            Icons.notifications_active_rounded,
            widget.isArabic ? 'إشعار' : 'Notify',
            Colors.green,
            widget.onNotify,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.red.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.archive_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              widget.isArabic ? 'مؤرشف' : 'Archived',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogsViewer extends StatelessWidget {
  final Package package;
  final bool isArabic;

  const LogsViewer({
    super.key,
    required this.package,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 480,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF1E3A8A),
            const Color(0xFF1E40AF),
          ]
              : [
            Colors.white,
            Colors.blue.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.blue.shade800, Colors.blue.shade900]
                    : [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.history_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'سجل الباقة' : 'Package Logs',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('yyyy/MM/dd').format(package.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: package.logs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد سجلات' : 'No logs available',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: package.logs.length,
              itemBuilder: (_, i) {
                final log = package.logs[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.blue.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      log.message,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}