// ============= API Service =============
import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';

class PaymentApiService {
  static final String baseUrl = AppConfig.baseUrl;
  final String? authToken;

  PaymentApiService({this.authToken});

  Map<String, String> get headers => {'Content-Type': 'application/json'};

  Future<PaymentHistoryResponse> getPaymentHistory({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('${baseUrl}Payments/history')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PaymentHistoryResponse.fromJson(data);
      } else {
        throw Exception('Failed to load payment history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading payment history: $e');
    }
  }

  Future<CustomerSubscriptionsResponse> getCustomerSubscriptions({
    String? search,
    String? status,
    bool sortAscending = true,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        'sortAscending': sortAscending.toString(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('${baseUrl}Payments/customer-subscriptions')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CustomerSubscriptionsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading subscriptions: $e');
    }
  }

  Future<bool> renewSubscription(int subscriptionId) async {
    try {
      final uri = Uri.parse('${baseUrl}Payments/renew-subscription/$subscriptionId');
      final response = await http.post(uri, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error renewing subscription: $e');
    }
  }

  Future<PaymentStats> getPaymentStats() async {
    try {
      final uri = Uri.parse('${baseUrl}Payments/stats');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PaymentStats.fromJson(data);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }
}

// ============= Models =============
class Payment {
  final int id;
  final String paymentId;
  final String username;
  final String plan;
  final double amount;
  final String status;
  final String method;
  final DateTime date;

  Payment({
    required this.id,
    required this.paymentId,
    required this.username,
    required this.plan,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentId: json['paymentId'] ?? '',
      username: json['username'] ?? '',
      plan: json['plan'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      method: json['method'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}

class PaymentHistoryResponse {
  final List<Payment> payments;
  final int totalCount;
  final int page;
  final int pageSize;

  PaymentHistoryResponse({
    required this.payments,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryResponse(
      payments: (json['payments'] as List).map((p) => Payment.fromJson(p)).toList(),
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

class CustomerSubscription {
  final int id;
  final String name;
  final String packageName;
  final DateTime endDate;
  final bool isActive;

  CustomerSubscription({
    required this.id,
    required this.name,
    required this.packageName,
    required this.endDate,
    required this.isActive,
  });

  factory CustomerSubscription.fromJson(Map<String, dynamic> json) {
    return CustomerSubscription(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      packageName: json['packageName'] ?? '',
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
    );
  }
}

class CustomerSubscriptionsResponse {
  final List<CustomerSubscription> subscriptions;
  final int totalCount;
  final int page;
  final int pageSize;

  CustomerSubscriptionsResponse({
    required this.subscriptions,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory CustomerSubscriptionsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerSubscriptionsResponse(
      subscriptions: (json['subscriptions'] as List)
          .map((s) => CustomerSubscription.fromJson(s))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 5,
    );
  }
}

class PaymentStats {
  final double totalRevenue;
  final int totalPayments;
  final int activeSubscriptions;
  final int pendingPayments;

  PaymentStats({
    required this.totalRevenue,
    required this.totalPayments,
    required this.activeSubscriptions,
    required this.pendingPayments,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalPayments: json['totalPayments'] ?? 0,
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
    );
  }
}

// ============= ViewModels =============
class PaymentViewModel extends ChangeNotifier {
  final PaymentApiService _apiService;

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  PaymentViewModel({String? authToken})
      : _apiService = PaymentApiService(authToken: authToken);

  Future<void> loadPayments({bool refresh = false}) async {
    if (refresh) _currentPage = 1;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPaymentHistory(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        pageSize: 10,
      );

      _payments = response.payments;
      _totalPages = (response.totalCount / response.pageSize).ceil();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    loadPayments(refresh: true);
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await loadPayments();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await loadPayments();
    }
  }

  Future<void> exportToCSV() async {
    final List<List<String>> rows = [
      ['الاسم', 'الباقة', 'المبلغ', 'الحالة', 'الوسيلة', 'التاريخ'],
      ..._payments.map((p) => [
        p.username,
        p.plan,
        p.amount.toString(),
        p.status,
        p.method,
        p.date.toIso8601String(),
      ])
    ];

    try {
      final csvContent = const ListToCsvConverter().convert(rows);
      final bytes = csvContent.codeUnits;
      await FileSaver.instance.saveFile(
        name: 'سجل_المدفوعات.csv',
        bytes: Uint8List.fromList(bytes),
        ext: 'csv',
        mimeType: MimeType.csv,
      );
    } catch (e) {
      debugPrint('خطأ أثناء التصدير: $e');
    }
  }
}

class CustomerSubscriptionViewModel extends ChangeNotifier {
  final PaymentApiService _apiService;

  List<CustomerSubscription> _subscriptions = [];
  List<CustomerSubscription> get subscriptions => _subscriptions;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'الكل';
  String get statusFilter => _statusFilter;

  bool _sortAscending = true;
  bool get sortAscending => _sortAscending;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  CustomerSubscriptionViewModel({String? authToken})
      : _apiService = PaymentApiService(authToken: authToken);

  Future<void> loadSubscriptions({bool refresh = false}) async {
    if (refresh) _currentPage = 1;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCustomerSubscriptions(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter == 'الكل' || _statusFilter == 'All' ? null : _statusFilter,
        sortAscending: _sortAscending,
        page: _currentPage,
        pageSize: 5,
      );

      _subscriptions = response.subscriptions;
      _totalPages = (response.totalCount / response.pageSize).ceil();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading subscriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    loadSubscriptions(refresh: true);
  }

  void updateStatusFilter(String filter) {
    _statusFilter = filter;
    loadSubscriptions(refresh: true);
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    loadSubscriptions(refresh: true);
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await loadSubscriptions();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await loadSubscriptions();
    }
  }

  Future<bool> renewSubscription(int subscriptionId) async {
    try {
      final success = await _apiService.renewSubscription(subscriptionId);
      if (success) await loadSubscriptions();
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error renewing subscription: $e');
      notifyListeners();
      return false;
    }
  }
}
class PaymentStatsViewModel extends ChangeNotifier {
  final PaymentApiService _apiService;

  PaymentStats? _stats;
  PaymentStats? get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DateTime? _lastUpdate;
  DateTime? get lastUpdate => _lastUpdate;

  String _selectedPeriod = 'شهري';
  String get selectedPeriod => _selectedPeriod;

  PaymentStatsViewModel({String? authToken})
      : _apiService = PaymentApiService(authToken: authToken);

  // جلب الإحصائيات من الـ API
  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _apiService.getPaymentStats();
      _lastUpdate = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    // يمكنك هنا إضافة API call جديد حسب الفترة المختارة
    // loadStats();
  }
}
