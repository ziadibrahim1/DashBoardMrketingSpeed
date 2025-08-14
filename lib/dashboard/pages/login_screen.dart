import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../providers/app_providers.dart';
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

  void handleLogin(bool isArabic) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            currentUserName: email,
            onLogout: () {
              // عند تسجيل الخروج، نرجع لشاشة تسجيل الدخول مجدداً
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            onThemeToggle: () {
            },
            onLanguageToggle: () {
            },
            isArabic:  isArabic,
          ),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'يرجى إدخال البريد وكلمة المرور';
      });
    }
  }
  void showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).resetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).resetPasswordContent),
            const SizedBox(height: 10),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: S.of(context).emailLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(S.of(context).send),
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).resetEmailSent(email))),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final primary = isDarkMode ? Colors.green[700] : Colors.blue;
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                ? [Colors.green.shade900, Colors.black]
                : [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    color: Colors.blue.withOpacity(0.3),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.language,
                            color: isDarkMode ? Colors.white : Colors.black54,
                          ),
                          tooltip: 'Toggle Language',
                          onPressed: () {
                            localeProvider.toggleLocale();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: isDarkMode ? Colors.white : Colors.black54,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: () {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),

                    Text(
                      S.of(context).loginTitle,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black.withOpacity(.6),
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: S.of(context).emailLabel),
                      validator: (value) =>
                      value!.isEmpty ? S.of(context).emailEmptyError : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: S.of(context).passwordLabel),
                      obscureText: true,
                      validator: (value) =>
                      value!.isEmpty ? S.of(context).passwordEmptyError : null,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: showForgotPasswordDialog,
                        child: Text(
                          S.of(context).forgotPassword,
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black.withOpacity(.6)),
                        ),
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
                            handleLogin(isArabic);
                          }
                        },
                        child: Text(
                          S.of(context).loginButton,
                          style: const TextStyle(color: Colors.white),
                        ),
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
