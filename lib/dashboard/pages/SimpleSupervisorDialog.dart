// --- شاشة إضافة / تعديل المستخدم ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'SupervisorsManagementScreen.dart';

// --- شاشة إضافة / تعديل المستخدم ---
class AddEditUserWidget extends StatefulWidget {
  final User? user;
  final bool isSupervisor;
  final bool isArabic;
  final VoidCallback onCancel;
  final Function(User) onSave;
  final String Function() generateReviewLink;

  const AddEditUserWidget({
    Key? key,
    required this.user,
    required this.isSupervisor,
    required this.isArabic,
    required this.onCancel,
    required this.onSave,
    required this.generateReviewLink,
  }) : super(key: key);

  @override
  State<AddEditUserWidget> createState() => _AddEditUserWidgetState();
}

class _AddEditUserWidgetState extends State<AddEditUserWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _bankController;
  late TextEditingController _accountNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  // بيانات المسوق فقط
  late TextEditingController _pointsController;
  late TextEditingController _pointPriceController;
  late TextEditingController _discountCodeController;
  late TextEditingController _reviewLinkController;
  late TextEditingController _totalDueAmountController;

  String tr(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final user = widget.user!;
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _countryController = TextEditingController(text: user.country);
      _cityController = TextEditingController(text: user.city);
      _bankController = TextEditingController(text: user.bank);
      _accountNumberController = TextEditingController(text: user.accountNumber);
      _phoneController = TextEditingController(text: user.phone);
      _emailController = TextEditingController(text: user.email);
      _passwordController = TextEditingController(text: user.password);
      if (!widget.isSupervisor && user is Marketer) {
        _pointsController = TextEditingController(text: user.points.toString());
        _pointPriceController =
            TextEditingController(text: user.pointPrice.toString());
        _discountCodeController = TextEditingController(text: user.discountCode);
        _reviewLinkController = TextEditingController(text: user.reviewLink);
        _totalDueAmountController =
            TextEditingController(text: user.totalDueAmount.toString());
      } else {
        _pointsController = TextEditingController();
        _pointPriceController = TextEditingController();
        _discountCodeController = TextEditingController();
        _reviewLinkController = TextEditingController();
        _totalDueAmountController = TextEditingController();
      }
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _countryController = TextEditingController();
      _cityController = TextEditingController();
      _bankController = TextEditingController();
      _accountNumberController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _passwordController = TextEditingController();

      _pointsController = TextEditingController();
      _pointPriceController = TextEditingController();
      _discountCodeController = TextEditingController();
      _reviewLinkController =
          TextEditingController(text: widget.generateReviewLink());
      _totalDueAmountController = TextEditingController();
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final country = _countryController.text.trim();
      final city = _cityController.text.trim();
      final bank = _bankController.text.trim();
      final accountNumber = _accountNumberController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (widget.isSupervisor) {
        final newSupervisor = Supervisor(
          firstName: firstName,
          lastName: lastName,
          country: country,
          city: city,
          bank: bank,
          accountNumber: accountNumber,
          phone: phone,
          email: email,
          password: password,
          status: widget.user?.status ?? UserStatus.active,
          marketers: widget.user is Supervisor
              ? (widget.user as Supervisor).marketers
              : [],
        );
        widget.onSave(newSupervisor);
      } else {
        final points = int.tryParse(_pointsController.text) ?? 0;
        final pointPrice = double.tryParse(_pointPriceController.text) ?? 0;
        final discountCode = _discountCodeController.text.trim();
        final reviewLink = _reviewLinkController.text.trim();
        final totalDueAmount = double.tryParse(_totalDueAmountController.text) ?? 0;

        final newMarketer = Marketer(
          firstName: firstName,
          lastName: lastName,
          country: country,
          city: city,
          bank: bank,
          accountNumber: accountNumber,
          phone: phone,
          email: email,
          password: password,
          points: points,
          pointPrice: pointPrice,
          discountCode: discountCode,
          reviewLink: reviewLink.isEmpty
              ? widget.generateReviewLink()
              : reviewLink,
          totalDueAmount: totalDueAmount,
          status: widget.user?.status ?? UserStatus.active,
        );
        widget.onSave(newMarketer);
      }
    }
  }
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textFieldStyle =  isDark ? Color(0xFFD7EFDC) : Colors.blue[900];
    // متغير حالة الاظهار/الإخفاء
    return Scaffold(
      backgroundColor:isDark?Colors.grey[900]: Colors.grey[100],
      body: Center(
        child:Card (
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          clipBehavior: Clip.hardEdge,
          child:
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color:isDark? Colors.grey[850]!:Colors.white.withOpacity(0.7),
                    blurRadius: 12,
                    offset: const Offset(0, 8))
              ],
            ),
            child:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: tr('رجوع', 'Back'),
                      onPressed: widget.onCancel,
                    ),
                    Expanded(
                      child: Text(
                        widget.user == null
                            ? (widget.isSupervisor
                            ? tr('إضافة مشرف', 'Add Supervisor')
                            : tr('إضافة مسوق', 'Add Marketer'))
                            : (widget.isSupervisor
                            ? tr('تعديل مشرف', 'Edit Supervisor')
                            : tr('تعديل مسوق', 'Edit Marketer')),
                        textAlign: TextAlign.center,
                        style:
                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:textFieldStyle),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration:
                            InputDecoration(labelText: tr('الاسم الأول', 'First Name')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال الاسم الأول', 'Please enter first name')
                                : null,
                            style:
                            TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration:
                            InputDecoration(labelText: tr('الاسم الأخير', 'Last Name')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال الاسم الأخير', 'Please enter last name')
                                : null,
                            style:
                            TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _countryController,
                            decoration: InputDecoration(labelText: tr('الدولة', 'Country')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال الدولة', 'Please enter country')
                                : null,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(labelText: tr('المدينة', 'City')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال المدينة', 'Please enter city')
                                : null,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bankController,
                            decoration: InputDecoration(labelText: tr('البنك', 'Bank')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال اسم البنك', 'Please enter bank name')
                                : null,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _accountNumberController,
                            decoration: InputDecoration(labelText: tr('رقم الحساب', 'Account Number')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال رقم الحساب', 'Please enter account number')
                                : null,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(labelText: tr('رقم الهاتف', 'Phone')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال رقم الهاتف', 'Please enter phone number')
                                : null,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: tr('البريد الإلكتروني', 'Email')),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('الرجاء إدخال البريد الإلكتروني', 'Please enter email')
                                : null,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color:textFieldStyle),
                          ),
                          const SizedBox(height: 16),
                          if (widget.isSupervisor) ...[
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: tr('كلمة المرور', 'Password'),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.text,  // عادة الباسورد يكون text وليس number
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return tr('الرجاء إدخال كلمة المرور', 'Please enter password');
                                return null;
                              },
                              style: TextStyle(color:textFieldStyle),
                            ),
                          ],
                          if (!widget.isSupervisor) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pointsController,
                              decoration: InputDecoration(labelText: tr('النقاط المجمعه', 'Points Collected')),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return tr('الرجاء إدخال النقاط', 'Please enter points');
                                if (int.tryParse(v) == null) return tr('يجب إدخال رقم صحيح', 'Must be a valid number');
                                return null;
                              },
                              style: TextStyle(color:textFieldStyle),
                            ),
                            TextFormField(
                              controller: _pointPriceController,
                              decoration: InputDecoration(labelText: tr('سعر النقاط', 'Point Price')),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return tr('الرجاء إدخال سعر النقاط', 'Please enter point price');
                                if (double.tryParse(v) == null) return tr('يجب إدخال رقم صحيح', 'Must be a valid number');
                                return null;
                              },
                              style: TextStyle(color:textFieldStyle),
                            ),
                            TextFormField(
                              controller: _discountCodeController,
                              decoration: InputDecoration(
                                labelText: tr('كود الخصم', 'Discount Code'),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: tr('نسخ الكود', 'Copy Code'),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _discountCodeController.text));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(tr('تم نسخ الكود', 'Code copied'))),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              style: TextStyle(color:textFieldStyle),
                            ),
                            TextFormField(
                              controller: _reviewLinkController,
                              decoration: InputDecoration(
                                labelText: tr('لينك المراجعه', 'Review Link'),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: tr('نسخ اللينك', 'Copy Link'),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _reviewLinkController.text));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(tr('تم نسخ اللينك', 'Link copied'))),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh),
                                      tooltip: tr('تجديد الرابط', 'Renew Link'),
                                      onPressed: () {
                                        setState(() {
                                          _reviewLinkController.text = widget.generateReviewLink();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              style: TextStyle(color:textFieldStyle),
                            ),
                            TextFormField(
                              controller: _totalDueAmountController,
                              decoration: InputDecoration(labelText: tr('اجمالي المبلغ المستحق', 'Total Due Amount')),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return tr('الرجاء إدخال المبلغ المستحق', 'Please enter due amount');
                                if (double.tryParse(v) == null) return tr('يجب إدخال رقم صحيح', 'Must be a valid number');
                                return null;
                              },
                              style: TextStyle(color:textFieldStyle),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark?Colors.green: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _save,
                            child: Text(widget.user == null
                                ? (widget.isSupervisor ? tr('إضافة', 'Add') : tr('إضافة مسوق', 'Add Marketer'))
                                : tr('حفظ التعديلات', 'Save Changes')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),),
        ),
      ),
    );
  }
}
