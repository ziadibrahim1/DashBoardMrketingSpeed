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

  final Color primaryColor = const Color(0xFF0F172A); // Navy Slate
  final Color accentColor = const Color(0xFF3B82F6); // Electric Blue

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    pendingFuture = WithdrawalsService.fetchPending();
    historyFuture = WithdrawalsService.fetchHistory();
  }

  void reload() {
    setState(() => _loadData());
  }
 @override


 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: const Color(0xFFF8FAFC),
     // إضافة زر التحديث كزر عائم
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
           expandedHeight: 85.0,
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
                   colors: [
                     Color(0xFF4FA8ED),
                     Color(0xFF1F61CD),
                   ],
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

           // تم إزالة زر التحديث من هنا ليصبح زراً عائماً
           actions: const [
             SizedBox(width: 48),
           ],
           bottom: PreferredSize(
             preferredSize: const Size.fromHeight(70),
             child: Container(
               margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
                 labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
           _buildReportBar(),
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

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: items.length,
          itemBuilder: (context, i) => _buildModernCard(items[i], showActions),
        );
      },
    );
  }

  Widget _buildModernCard(WithdrawalRequest w, bool showActions) {
    // تحديد الألوان بناءً على الحالة لضمان الوضوح التام
    final bool isPending = w.status == 'pending' || w.status == null;
    final bool isApproved = w.status == 'approved';
    final bool isRejected = w.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ظل ناعم جداً ليعطي عمقاً بسيطاً
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
          // 1. الجزء العلوي: اسم المسوق والمبلغ (ألوان زاهية)
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
                    _buildStatusText(w.status), // عرض نص الحالة دائماً
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // 2. عرض جميع البيانات (بدون إخفاء أي حقل)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDataLine(Icons.auto_awesome, 'النقاط المستبدلة', '${w.points} نقطة', Colors.orange),
                _buildDataLine(Icons.account_balance, 'البنك المستلم', w.bank, Colors.indigo),
                _buildDataLine(Icons.credit_card, 'رقم الحساب', w.accountNumber, Colors.blueGrey),

                // عرض سبب الرفض إن وجد
                if (isRejected && w.rejectReason != null)
                  _buildDataLine(Icons.info_outline, 'سبب الرفض', w.rejectReason!, Colors.red),

                // عرض تفاصيل الصرف كاملة في السجل (دائماً ظاهرة)
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

          // 3. أزرار التحكم (تظهر فقط في التبويب المعلق)
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

// ويدجت لعرض سطر بيانات بسيط وزاهي
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

// ويدجت نص الحالة
  Widget _buildStatusText(String? status) {
    String text = 'قيد الانتظار';
    Color color = Colors.orange;
    if (status == 'approved') { text = 'تم الصرف'; color = Colors.green; }
    if (status == 'rejected') { text = 'مرفوض'; color = Colors.red; }

    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color));
  }
  Widget _buildAvatar(String name) {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(name[0], style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 20))),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange);
    String text = status == 'approved' ? 'مكتمل' : (status == 'rejected' ? 'مرفوض' : 'معلق');
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey.shade300),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 12)),
      ],
    );
  }

  Widget _buildPayoutDetails(WithdrawalRequest w) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.withOpacity(0.1))),
      child: Column(
        children: [
          _pRow('المرجع', w.payout!.referenceNumber),
          _pRow('التاريخ', w.payout!.paidAt.toString().split(' ')[0]),
        ],
      ),
    );
  }

  Widget _pRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRejectReason(String? reason) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Text('سبب الرفض: ${reason ?? "غير محدد"}', style: const TextStyle(color: Colors.red, fontSize: 11)),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.white,
        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _buildStatusEmpty(IconData icon, String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 60, color: Colors.blueGrey.shade100),
      const SizedBox(height: 10),
      Text(msg, style: TextStyle(color: Colors.blueGrey.shade300)),
    ]));
  }

  // --- ديالوجات محسنة ---
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
              const Text(
                'تأكيد الدفع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
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

                // حقل طريقة الدفع
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

                // حقل رقم المرجع
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
                      // يمكنك إضافة Validation هنا للتأكد من تعبئة الحقول
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