import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/AdminUser.dart';
import '../../providers/app_providers.dart';
import 'SendMessageDialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminApi api = AdminApi();
  late Future<List<AdminUser>> usersFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _subscriptionFilter = 'all';
  String _connectionFilter = 'all';

  @override
  void initState() {
    super.initState();
    usersFuture = api.getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'active':
      case 'connected':
        return const Color(0xFF2196F3);
      case 'expired':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFF44336);
    }
  }

  String _getStatusText(String status, BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    switch (status) {
      case 'active':
        return appLocalizations.translate('active');
      case 'expired':
        return appLocalizations.translate('expired');
      case 'connected':
        return appLocalizations.translate('connected');
      case 'disconnected':
        return appLocalizations.translate('disconnected');
      default:
        return status;
    }
  }

  List<AdminUser> _filterUsers(List<AdminUser> users) {
    return users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSubscription = _subscriptionFilter == 'all' ||
          user.subscriptionStatus == _subscriptionFilter;

      final matchesConnection = _connectionFilter == 'all' ||
          user.connectionStatus == _connectionFilter;

      return matchesSearch && matchesSubscription && matchesConnection;
    }).toList();
  }

  void _showFilterSheet(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appLocalizations.translate('filter_results'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _subscriptionFilter = 'all';
                      _connectionFilter = 'all';
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFF1976D2)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              appLocalizations.translate('subscription_status'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(appLocalizations.translate('all'), 'all', _subscriptionFilter, (val) {
                  setState(() => _subscriptionFilter = val);
                }),
                _buildFilterChip(appLocalizations.translate('active'), 'active', _subscriptionFilter, (val) {
                  setState(() => _subscriptionFilter = val);
                }),
                _buildFilterChip(appLocalizations.translate('expired'), 'expired', _subscriptionFilter, (val) {
                  setState(() => _subscriptionFilter = val);
                }),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              appLocalizations.translate('connection_status'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(appLocalizations.translate('all'), 'all', _connectionFilter, (val) {
                  setState(() => _connectionFilter = val);
                }),
                _buildFilterChip(appLocalizations.translate('connected'), 'connected', _connectionFilter, (val) {
                  setState(() => _connectionFilter = val);
                }),
                _buildFilterChip(appLocalizations.translate('disconnected'), 'disconnected', _connectionFilter, (val) {
                  setState(() => _connectionFilter = val);
                }),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  appLocalizations.translate('apply'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentValue, Function(String) onTap) {
    final isSelected = currentValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(value),
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF1976D2).withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: const Color(0xFF1976D2),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
      ),
    );
  }

  void openMessagesLog(BuildContext context, AdminUser user) {
    final appLocalizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<List<MessageLog>>(
            future: api.getUserMessages(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                );
              }

              final messages = snapshot.data ?? [];

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mail_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${appLocalizations.translate('message_log')} ${user.name}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${messages.length} ${appLocalizations.translate('message')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appLocalizations.translate('no_messages'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.message,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: m.status == 'sent'
                                          ? const Color(0xFF1976D2).withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.status == 'sent'
                                          ? appLocalizations.translate('sent')
                                          : appLocalizations.translate('failed'),
                                      style: TextStyle(
                                        color: m.status == 'sent'
                                            ? const Color(0xFF1976D2)
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.recipient,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${m.createdAt}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void openSendDialog(BuildContext context, AdminUser user) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            child: SendMessageDialog(user: user),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Card
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient:  LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            appLocalizations.translate('send_management'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                                decoration: InputDecoration(
                                  hintText: appLocalizations.translate('search_user'),
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF1976D2),
                                    size: 20,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                    iconSize: 18,
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 20,
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.filter_list,
                                    color: Color(0xFF1976D2),
                                  ),
                                  if (_subscriptionFilter != 'all' ||
                                      _connectionFilter != 'all')
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () => _showFilterSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // قائمة المستخدمين
            Expanded(
              child: FutureBuilder<List<AdminUser>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                      ),
                    );
                  }

                  final users = _filterUsers(snapshot.data ?? []);

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appLocalizations.translate('no_results'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appLocalizations.translate('try_changing_search'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final user = users[i];
                      final canSend = user.subscriptionStatus == 'active' &&
                          user.connectionStatus == 'connected';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212121),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor(user.subscriptionStatus).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: statusColor(user.subscriptionStatus),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getStatusText(user.subscriptionStatus, context),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor(user.subscriptionStatus),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor(user.connectionStatus).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: statusColor(user.connectionStatus),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getStatusText(user.connectionStatus, context),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor(user.connectionStatus),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.phone_android, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              user.phone?.isNotEmpty == true
                                                  ? "0${user.phone}"
                                                  : appLocalizations.translate('not_available'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: const Color(0xFF1976D2).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        onTap: () => openMessagesLog(context, user),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.history,
                                                size: 16,
                                                color: Color(0xFF1976D2),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                appLocalizations.translate('log'),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1976D2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Material(
                                      color: canSend
                                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        onTap: canSend ? () => openSendDialog(context, user) : null,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.send,
                                                size: 16,
                                                color: canSend ? const Color(0xFF4CAF50) : Colors.grey,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                appLocalizations.translate('send'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: canSend ? const Color(0xFF4CAF50) : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AppLocalizations {
  final BuildContext context;

  AppLocalizations(this.context);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(context);
  }

  // دالة للحصول على الـlocale الحالي
  Locale get _currentLocale {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale;
  }

  // الخريطة بالترجمات
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'send_management': 'Send Management',
      'search_user': 'Search for a user...',
      'filter_results': 'Filter Results',
      'subscription_status': 'Subscription Status',
      'connection_status': 'Connection Status',
      'all': 'All',
      'active': 'Active',
      'expired': 'Expired',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'apply': 'Apply',
      'message_log': 'Message log for',
      'message': 'message',
      'messages': 'messages',
      'no_messages': 'No messages',
      'sent': 'Sent',
      'failed': 'Failed',
      'no_results': 'No results',
      'try_changing_search': 'Try changing search or filter criteria',
      'not_available': 'Not available',
      'log': 'Log',
      'send': 'Send',
    },
    'ar': {
      'send_management': 'إدارة الإرسال',
      'search_user': 'البحث عن مستخدم...',
      'filter_results': 'تصفية النتائج',
      'subscription_status': 'حالة الاشتراك',
      'connection_status': 'حالة الاتصال',
      'all': 'الكل',
      'active': 'نشط',
      'expired': 'منتهي',
      'connected': 'متصل',
      'disconnected': 'غير متصل',
      'apply': 'تطبيق',
      'message_log': 'سجل رسائل',
      'message': 'رسالة',
      'messages': 'رسائل',
      'no_messages': 'لا توجد رسائل',
      'sent': 'تم الإرسال',
      'failed': 'فشل',
      'no_results': 'لا توجد نتائج',
      'try_changing_search': 'جرب تغيير معايير البحث أو الفلترة',
      'not_available': 'غير متوفر',
      'log': 'السجل',
      'send': 'إرسال',
    },
  };

  String translate(String key) {
    final localeCode = _currentLocale.languageCode;
    return _localizedValues[localeCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale as BuildContext);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}