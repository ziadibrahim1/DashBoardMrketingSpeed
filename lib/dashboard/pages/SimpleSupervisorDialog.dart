import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/app_config.dart';
import 'SupervisorsManagementScreen.dart';

class AddEditUserWidget extends StatefulWidget {
  final User? user;
  final bool addSuper;
  final bool addMarketer;
  final bool isSupervisor;
  final bool isAdmin;
  final bool isArabic;
  final VoidCallback onCancel;
  final Function(User) onSave;
  final String Function() generateReviewLink;
  final int? supervisorId;

  const AddEditUserWidget({
    Key? key,
    required this.user,
    required this.addSuper,
    required this.addMarketer,
    required this.isSupervisor,
    required this.isAdmin,
    required this.isArabic,
    required this.onCancel,
    required this.onSave,
    required this.generateReviewLink,
    this.supervisorId,
  }) : super(key: key);

  @override
  State<AddEditUserWidget> createState() => _AddEditUserWidgetState();
}

class _AddEditUserWidgetState extends State<AddEditUserWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _emailVerified = false;
  bool _sendingCode = false;
  bool _verifyingCode = false;
  bool _enablePasswordEdit = false; // متغير جديد للتحكم في تفعيل تعديل كلمة المرور

  late TextEditingController _firstNameController, _lastNameController, _countryController,
      _cityController, _ageController, _bankController, _accountNumberController,
      _phoneController, _emailController, _passwordController, _pointsController,
      _pointPriceController, _discountCodeController, _reviewLinkController, _totalDueAmountController;

  final TextEditingController _emailCodeController = TextEditingController();

  String tr(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.user != null) {
      _emailVerified = true;
      _enablePasswordEdit = false; // في حالة التعديل، الحقل معطل افتراضياً
    } else {
      _enablePasswordEdit = true; // في حالة الإضافة، الحقل مفعل
    }
  }

  void _initializeControllers() {
    final user = widget.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _bankController = TextEditingController(text: user?.bank ?? '');
    _accountNumberController = TextEditingController(text: user?.accountNumber ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController(text: ''); // فارغ في حالة التعديل

    _pointsController = TextEditingController(text: (user is Marketer) ? user.points.toString() : '0');
    _pointPriceController = TextEditingController(text: (user is Marketer) ? user.pointPrice.toString() : '0');
    _discountCodeController = TextEditingController(text: (user is Marketer) ? user.discountCode : '');
    _reviewLinkController = TextEditingController(text: (user is Marketer) ? user.reviewLink : widget.generateReviewLink());
    _totalDueAmountController = TextEditingController(text: (user is Marketer) ? user.totalDueAmount.toString() : '0');
  }

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return tr('البريد مطلوب', 'Email is required');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return tr('بريد إلكتروني غير صالح', 'Invalid email format');
    return null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPhone = false,
    bool isIBAN = false,
    bool isEmail = false,
    bool isPassword = false,
    bool isNumberOnly = false,
    bool isDecimal = false,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword ? _obscurePassword : false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        keyboardType: (isPhone || isNumberOnly || isDecimal) ? TextInputType.number : TextInputType.text,
        inputFormatters: [
          if (isNumberOnly) FilteringTextInputFormatter.digitsOnly,
          if (isDecimal) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          if (isPhone) ...[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
          if (isIBAN) ...[FilteringTextInputFormatter.allow(RegExp(r'[sSaA0-9]')), LengthLimitingTextInputFormatter(24)],
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.blueAccent.withOpacity(0.7), size: 20),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: (v) {
          // في حالة كلمة المرور: إذا كان في وضع التعديل وغير مفعل، لا نحتاج للتحقق
          if (isPassword && widget.user != null && !_enablePasswordEdit) {
            return null;
          }

          if (v == null || v.trim().isEmpty) return tr('هذا الحقل مطلوب', 'Required');
          if (isPhone) {
            if (v.startsWith('05')) { if (v.length != 10) return tr('يجب أن يكون 10 أرقام', 'Must be 10 digits'); }
            else if (v.startsWith('966')) { if (v.length != 12) return tr('يجب أن يكون 12 رقم', 'Must be 12 digits'); }
            else { return tr('يجب أن يبدأ بـ 05 أو 966', 'Start with 05 or 966'); }
          }
          if (isIBAN) {
            if (!v.toUpperCase().startsWith('SA')) return tr('يجب أن يبدأ بـ SA', 'Must start with SA');
            if (v.length != 24) return tr('يجب أن يتكون من SA + 22 رقم', 'Must be SA + 22 digits');
          }
          if (isEmail) return emailValidator(v);
          if (isPassword && v.length < 8) return tr('8 أحرف على الأقل', 'Min 8 characters');
          return null;
        },
      ),
    );
  }

  // حقل كلمة المرور الجديد مع زر التفعيل
  Widget _buildPasswordField() {
    bool isEditMode = widget.user != null;

    return Column(
      children: [
        // زر التفعيل (يظهر فقط في وضع التعديل)
        if (isEditMode)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _enablePasswordEdit ? Colors.orange.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _enablePasswordEdit ? Colors.orange.shade200 : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _enablePasswordEdit ? Icons.lock_open_rounded : Icons.lock_outline,
                  color: _enablePasswordEdit ? Colors.orange : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _enablePasswordEdit
                        ? tr('يمكنك الآن تعديل كلمة المرور', 'You can now edit password')
                        : tr('كلمة المرور لن يتم تعديلها', 'Password will not be changed'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _enablePasswordEdit ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ),
                Switch(
                  value: _enablePasswordEdit,
                  onChanged: (value) {
                    setState(() {
                      _enablePasswordEdit = value;
                      if (!value) {
                        _passwordController.clear(); // مسح الحقل عند التعطيل
                      }
                    });
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),

        // حقل كلمة المرور
        _buildField(
          controller: _passwordController,
          label: tr('كلمة المرور', 'Password'),
          icon: Icons.lock_outline,
          isPassword: true,
          enabled: !isEditMode || _enablePasswordEdit, // مفعل في الإضافة أو عند تفعيل التعديل
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.user == null ? tr('إضافة جديد', 'Add New') : tr('تعديل البيانات', 'Edit Data'),
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueAccent, size: 20), onPressed: widget.onCancel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildModernSection(
                title: tr('المعلومات الشخصية', 'Personal Info'),
                icon: Icons.person_rounded,
                color: Colors.blueAccent,
                children: [
                  Row(children: [
                    Expanded(child: _buildField(controller: _firstNameController, label: tr('الأول', 'First'), icon: Icons.badge)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(controller: _lastNameController, label: tr('الأخير', 'Last'), icon: Icons.badge_outlined)),
                  ]),
                  _buildEmailVerificationSection(),
                  _buildField(controller: _phoneController, label: tr('رقم الهاتف (05/966)', 'Phone'), icon: Icons.phone_android, isPhone: true),
                  _buildPasswordField(), // استخدام الحقل الجديد
                ],
              ),
              _buildModernSection(
                title: tr('الموقع والعمر', 'Location & Age'),
                icon: Icons.map_rounded,
                color: Colors.teal,
                children: [
                  Row(children: [
                    Expanded(child: _buildField(controller: _countryController, label: tr('الدولة', 'Country'), icon: Icons.public)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(controller: _cityController, label: tr('المدينة', 'City'), icon: Icons.location_city)),
                  ]),
                  _buildField(controller: _ageController, label: tr('العمر', 'Age'), icon: Icons.cake_outlined, isNumberOnly: true),
                ],
              ),
              _buildModernSection(
                title: tr('البيانات المالية', 'Financial Info'),
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.orange.shade800,
                children: [
                  _buildField(controller: _bankController, label: tr('البنك', 'Bank'), icon: Icons.account_balance),
                  _buildField(controller: _accountNumberController, label: tr('رقم الحساب (IBAN)', 'IBAN'), icon: Icons.credit_card, isIBAN: true),
                ],
              ),
              if (widget.isAdmin)
                _buildModernSection(
                  title: tr('إحصائيات النقاط', 'Points Stats'),
                  icon: Icons.auto_graph_rounded,
                  color: Colors.purple,
                  children: [
                    Row(children: [
                      Expanded(child: _buildField(controller: _pointsController, label: tr('النقاط', 'Points'), icon: Icons.toll, isNumberOnly: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(controller: _pointPriceController, label: tr('سعر النقطة', 'Price'), icon: Icons.attach_money, isDecimal: true)),
                    ]),
                  ],
                ),
              const SizedBox(height: 10),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailVerificationSection() {
    return Column(
      children: [
        _buildField(controller: _emailController, label: tr('البريد الإلكتروني', 'Email'), icon: Icons.email_outlined, isEmail: true, enabled: !_emailVerified),
        if (!_emailVerified)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(hintText: '000000', labelText: tr('كود التحقق', 'Code'), border: InputBorder.none, counterText: ""),
                      ),
                    ),
                    _sendingCode
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton.icon(onPressed: _sendEmailCode, icon: const Icon(Icons.send_rounded, size: 16), label: Text(tr('إرسال', 'Send'))),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyingCode ? null : _confirmEmailCode,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: _verifyingCode ? const CircularProgressIndicator(color: Colors.white) : Text(tr('تأكيد الكود', 'Confirm'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.verified_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 10),
              Text(tr('تم التحقق بنجاح', 'Verified Successfully'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
      ],
    );
  }

  Widget _buildModernSection({required String title, required IconData icon, required List<Widget> children, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 10),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: _save,
        child: Text(tr('حفظ الآن', 'Save Now'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (emailValidator(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('بريد إلكتروني غير صالح', 'Invalid email'))));
      return;
    }
    setState(() => _sendingCode = true);
    try {
      final res = await http.post(Uri.parse('${AppConfig.baseUrl}admin/verify/send-code'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email}));
      if (res.statusCode == 200) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('تم إرسال كود التحقق', 'Verification code sent'))));
      else throw Exception();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('فشل إرسال الكود', 'Failed to send code'))));
    } finally { setState(() => _sendingCode = false); }
  }

  Future<void> _confirmEmailCode() async {
    final email = _emailController.text.trim();
    final code = _emailCodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('أدخل كود صحيح', 'Enter valid code'))));
      return;
    }
    setState(() => _verifyingCode = true);
    try {
      final res = await http.post(Uri.parse('${AppConfig.baseUrl}admin/verify/confirm'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'code': code}));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() => _emailVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('تم التحقق من البريد بنجاح', 'Email verified successfully'))));
      } else throw Exception();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('كود غير صحيح أو منتهي', 'Invalid or expired code'))));
    } finally { setState(() => _verifyingCode = false); }
  }

  void _save() {
    if (!_emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('يجب التحقق من البريد الإلكتروني قبل الحفظ', 'Email must be verified before saving'))));
      return;
    }
    if (_formKey.currentState!.validate()) _executeSaveLogic();
  }

  void _executeSaveLogic() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final country = _countryController.text.trim();
    final city = _cityController.text.trim();
    final age = double.tryParse(_ageController.text.trim()) ?? 0;
    final bank = _bankController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    // منطق كلمة المرور الجديد
    String password;
    if (widget.user == null) {
      // في حالة الإضافة: استخدم كلمة المرور المدخلة
      password = _passwordController.text.trim();
    } else {
      // في حالة التعديل
      if (_enablePasswordEdit && _passwordController.text.trim().isNotEmpty) {
        // إذا تم تفعيل التعديل وتم إدخال كلمة مرور جديدة
        password = _passwordController.text.trim();
      } else {
        // إذا لم يتم تفعيل التعديل أو الحقل فارغ، أرسل "1"
        password = "1";
      }
    }

    if (widget.isSupervisor) {
      widget.onSave(Supervisor(
        id: widget.addSuper ? 0 : (widget.user as Supervisor).id,
        firstName: firstName, lastName: lastName, country: country, city: city,
        Age: age, bank: bank, accountNumber: accountNumber, phone: phone,
        Role: "Supervisor", email: email, password: password,
        status: widget.user?.status ?? UserStatus.active,
        marketers: widget.user is Supervisor ? (widget.user as Supervisor).marketers : [],
      ));
    } else {
      if (widget.supervisorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('يجب اختيار مشرف للمسوق', 'A supervisor must be selected'))));
        return;
      }
      widget.onSave(Marketer(
        id: widget.addMarketer ? 0 : (widget.user as Marketer).id,
        supervisorId: widget.supervisorId!,
        firstName: firstName, lastName: lastName, country: country, city: city,
        age: age, bank: bank, accountNumber: accountNumber, phone: phone,
        email: email, password: password,
        points: int.tryParse(_pointsController.text) ?? 0,
        pointPrice: double.tryParse(_pointPriceController.text) ?? 0,
        discountCode: _discountCodeController.text.trim(),
        totalDueAmount: double.tryParse(_totalDueAmountController.text) ?? 0,
        status: widget.user?.status ?? UserStatus.active,
        isWithdrawalPending: false,
      ));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose(); _lastNameController.dispose();
    _countryController.dispose(); _cityController.dispose();
    _ageController.dispose(); _bankController.dispose();
    _accountNumberController.dispose(); _phoneController.dispose();
    _emailController.dispose(); _passwordController.dispose();
    _pointsController.dispose(); _pointPriceController.dispose();
    _discountCodeController.dispose(); _reviewLinkController.dispose();
    _totalDueAmountController.dispose(); _emailCodeController.dispose();
    super.dispose();
  }
}