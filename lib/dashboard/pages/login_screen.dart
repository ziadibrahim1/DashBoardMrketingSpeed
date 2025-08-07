import 'package:flutter/material.dart';
import '../dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorMessage;

  void handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ✅ تحقق مبدئي (يمكن ربطه لاحقًا بـ API أو MySQL)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إعادة تعيين كلمة المرور"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين:"),
            const SizedBox(height: 10),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("إرسال"),
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إرسال رابط إعادة التعيين إلى $email')),
                );
                // يمكنك هنا ربط العملية بـ API فعلي لاحقاً
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? Colors.green[700] : Colors.blue;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية بها ضي أزرق
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // مركز الشاشة مع صندوق تسجيل الدخول وظله الأزرق
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    color: Colors.blue.withOpacity(0.3), // 🔵 هنا الضي الأزرق
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تسجيل دخول المسؤول',
                      style: TextStyle(
                        color: Colors.black.withOpacity(.6),
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                      validator: (value) => value!.isEmpty ? 'أدخل البريد' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'كلمة المرور'),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'أدخل كلمة المرور' : null,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: showForgotPasswordDialog,
                        child: const Text("نسيت كلمة المرور؟"),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primary),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            handleLogin();
                          }
                        },
                        child: const Text('دخول', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
