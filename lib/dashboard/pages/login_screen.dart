import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../generated/l10n.dart';
import '../../providers/app_providers.dart';
import '../dashboard_screen.dart';
import '../../core/web_session.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import 'MarketerProfileScreen.dart';
import 'SupervisorsManagementScreen.dart';

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
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(bool isArabic) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'يرجى إدخال البريد وكلمة المرور');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(AppConfig.loginUrl);

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print("RAW response from API: ${res.statusCode.toString()}");

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawUser = data['user'];

        // ----------------------------
        // 🔐 فك وترتيب الصلاحيات
        // ----------------------------
        final permissionsJson = rawUser['permissions_json'];
        Map<String, List<String>> parsedPermissions = {};

        if (permissionsJson != null && permissionsJson.toString().trim().isNotEmpty) {
          final decoded = jsonDecode(permissionsJson);
          decoded.forEach((key, value) {
            parsedPermissions[key] = List<String>.from(value);
          });
        }

        final user = {
          'id': rawUser['id'],
          'email': rawUser['email'],
          'firstName': rawUser['firstName'],
          'middleName': rawUser['middleName'],
          'lastName': rawUser['lastName'],
          'fullName': rawUser['fullName'],

          'phone': rawUser['phone'],
          'country': rawUser['country'],
          'city': rawUser['city'],
          'bank': rawUser['bank'],
          'iban': rawUser['iban'],
          'imagePath': rawUser['imagePath'],

          'role': rawUser['role'],
          'isActive': rawUser['isActive'],
          'langAr': rawUser['langAr'],
          'theme': rawUser['theme'],

          // 🌟 روابط النظام الجديدة
          'supervisorId': rawUser['supervisorId'],
          'marketerId': rawUser['marketerId'],
          'marketerSupervisorId': rawUser['marketerSupervisorId'],

          'permissions': parsedPermissions,
        };

        // ----------------------------
        // 💾 حفظ السيشن
        // ----------------------------
        UserSession.saveUser(user);
        print("RAW user from API: $user");

        // ----------------------------
        // 🚀 الانتقال للداشبورد
        // ----------------------------
        final role = (user['role'] ?? '').toString().toLowerCase();

        Widget targetScreen;

        if (role == 'admin') {
          targetScreen = DashboardScreen(
            currentUserName: (user['fullName'] ?? user['email'] ?? email).toString(),
            onLogout: () {
              WebSession.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            onThemeToggle: () {},
            onLanguageToggle: () {},
            isArabic: isArabic,
          );
        }
        else if (role == 'supervisor') {
          targetScreen = SupervisorsMarketersPage(); // 👈 صفحة المشرفين اللي عرضتها قبل كده
        }
        else if (role == 'marketer') {
          print("MARKETER ID: ${user['marketerId']}");
          targetScreen = MarketerProfileScreen();
        }
        else {
          setState(() => errorMessage = "Unknown role");
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );

      }

      // -------------- أخطاء تسجيل الدخول --------------
      else if (res.statusCode == 401) {
        setState(() => errorMessage = 'بيانات الدخول غير صحيحة');
      } else if (res.statusCode == 403) {
        setState(() => errorMessage = 'هذا الحساب غير مصرح له بالدخول');
      } else {

      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
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
  void initState() {
    super.initState();
    final user = WebSession.getUser();
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final isArabic = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode == 'ar';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              currentUserName: (user['fullName'] ?? user['email'] ?? '').toString(),
              onLogout: () {
                WebSession.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              onThemeToggle: () {},
              onLanguageToggle: () {},
              isArabic: isArabic,
            ),
          ),
        );
      });
    }
    if (user != null) {
      print("RAW permissions_json from API: ${user['permissions_json']}");

    }

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
                          onPressed: () => localeProvider.toggleLocale(),
                        ),
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: isDarkMode ? Colors.white : Colors.black54,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: () => themeProvider.toggleTheme(),
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
                      (value == null || value.isEmpty) ? S.of(context).emailEmptyError : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: S.of(context).passwordLabel),
                      obscureText: true,
                      validator: (value) =>
                      (value == null || value.isEmpty) ? S.of(context).passwordEmptyError : null,
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: showForgotPasswordDialog,
                        child: Text(
                          S.of(context).forgotPassword,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black.withOpacity(.6),
                          ),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            await handleLogin(isArabic);
                          }
                        },
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
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
