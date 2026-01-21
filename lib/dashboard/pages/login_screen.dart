import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isEmailHovered = false;
  bool _isPasswordHovered = false;
  bool _isLoginButtonHovered = false;

  late AnimationController _fadeController;
  late AnimationController _floatingController;
  late AnimationController _rippleController;
  late AnimationController _shakeController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shakeAnimation;

  final List<Particle> _particles = [];
  Timer? _particleTimer;
  Offset _mousePosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _fadeController.forward();
    _startParticles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = WebSession.getUser();
      if (user != null && mounted) {
        _navigateToUserScreen(user);
      }
    });
  }

  void _startParticles() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_particles.length < 30) {
        setState(() {
          _particles.add(Particle());
        });
      }
    });

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
        _particles.removeWhere((p) => p.isExpired);
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    _floatingController.dispose();
    _rippleController.dispose();
    _shakeController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _navigateToUserScreen(Map<String, dynamic> user) {
    if (!mounted) return;

    final isArabic = Provider.of<LocaleProvider>(context, listen: false)
        .locale
        .languageCode ==
        'ar';
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(
          currentUserName: (user['fullName'] ?? user['email'] ?? '').toString(),
          onLogout: _handleLogout,
          onThemeToggle: () {},
          onLanguageToggle: () {},
          isArabic: isArabic,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _handleLogout() {
    WebSession.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> handleLogin(bool isArabic) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        setState(() => errorMessage = 'يرجى إدخال البريد وكلمة المرور');
        _shakeController.forward(from: 0);
      }
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final uri = Uri.parse(AppConfig.loginUrl);

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawUser = data['user'];

        final permissionsJson = rawUser['permissions_json'];
        Map<String, List<String>> parsedPermissions = {};

        if (permissionsJson != null &&
            permissionsJson.toString().trim().isNotEmpty) {
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
          'supervisorId': rawUser['supervisorId'],
          'marketerId': rawUser['marketerId'],
          'marketerSupervisorId': rawUser['marketerSupervisorId'],
          'DashboardStatsSection': rawUser['DashboardStatsSection'],
          'UsersPage': rawUser['usersPage'],
          'AdminUsersScreen': rawUser['adminUsersScreen'],
          'SubscriptionsPage': rawUser['subscriptionsPage'],
          'PlatformManagementPage': rawUser['platformManagementPage'],
          'AdminManagementScreen': rawUser['adminManagementScreen'],
          'PackagesPage': rawUser['packagesPage'],
          'SocialAccountsPage': rawUser['socialAccountsPage'],
          'ReferralRewardsPage': rawUser['referralRewardsPage'],
          'SuggestionsManagementPage': rawUser['suggestionsManagementPage'],
          'SupervisorsMarketersPage': rawUser['supervisorsMarketersPage'],
          'WithdrawalsScreen': rawUser['withdrawalsScreen'],
          'ApiDashboardScreen': rawUser['apiDashboardScreen'],
          'PaymentManagementSection': rawUser['paymentManagementSection'],
          'VideoManagerScreen': rawUser['videoManagerScreen'],
          'StatsPage': rawUser['statsPage'],
          'StatsPageTelegram': rawUser['statsPageTelegram'],
          'AdminLiveChatDashboard': rawUser['adminLiveChatDashboard'],
          'AdminChatHistoryScreen': rawUser['adminChatHistoryScreen'],
          'SendNotificationPage': rawUser['sendNotificationPage'],
          'NotificationHistoryPage': rawUser['notificationHistoryPage'],
        };

        UserSession.saveUser(user);

        final role = (user['role'] ?? '').toString().toLowerCase();
        Widget targetScreen;

        if (role == 'admin' || role == 'user') {
          targetScreen = DashboardScreen(
            currentUserName:
            (user['fullName'] ?? user['email'] ?? email).toString(),
            onLogout: _handleLogout,
            onThemeToggle: () {},
            onLanguageToggle: () {},
            isArabic: isArabic,
          );
        } else if (role == 'supervisor') {
          targetScreen = SupervisorsMarketersPage();
        } else if (role == 'marketer') {
          targetScreen = MarketerProfileScreen();
        } else {
          if (mounted) setState(() => errorMessage = "Unknown role");
          return;
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      } else if (res.statusCode == 401) {
        if (mounted) {
          setState(() => errorMessage = 'بيانات الدخول غير صحيحة');
          _shakeController.forward(from: 0);
        }
      } else if (res.statusCode == 403) {
        if (mounted) {
          setState(() => errorMessage = 'هذا الحساب غير مصرح له بالدخول');
          _shakeController.forward(from: 0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => errorMessage = 'حدث خطأ في الاتصال');
        _shakeController.forward(from: 0);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      S.of(context).resetPasswordTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).resetPasswordContent,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: S.of(context).emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(S.of(context).cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final email = resetEmailController.text.trim();
                              if (email.isNotEmpty) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context).resetEmailSent(email)),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              S.of(context).send,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final primaryColor = isDarkMode ? const Color(0xFF00FFA3) : const Color(0xFF0066FF);
    final accentColor = isDarkMode ? const Color(0xFF00D4FF) : const Color(0xFF00B8FF);
    final backgroundColor = isDarkMode ? const Color(0xFF0A0F1C) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.position;
          });
        },
        child: Stack(
          children: [
            // Animated Background
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: isDarkMode
                      ? [
                    const Color(0xFF0A0F1C),
                    const Color(0xFF1A1F2C),
                    const Color(0xFF2A2F3C),
                  ]
                      : [
                    const Color(0xFFE6F7FF),
                    const Color(0xFFD1EDFF),
                    const Color(0xFFB8E1FF),
                  ],
                ),
              ),
            ),

            // Particles
            ...List.generate(_particles.length, (index) {
              if (index >= _particles.length) return const SizedBox.shrink();
              final particle = _particles[index];
              final clampedOpacity = particle.opacity.clamp(0.0, 1.0);
              return Positioned(
                left: particle.x,
                top: particle.y,
                child: Opacity(
                  opacity: clampedOpacity,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withOpacity(0.6 * clampedOpacity),
                          primaryColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Mouse Cursor Glow Effect
            Positioned(
              left: _mousePosition.dx - 50,
              top: _mousePosition.dy - 50,
              child: IgnorePointer(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Ripple Effect on Click
            if (_rippleController.isAnimating)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RipplePainter(
                        animation: _rippleAnimation.value,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade900.withOpacity(0.8)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 60,
                                offset: const Offset(0, 20),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Column(
                                children: [
                                  // Header with Animated Icon
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: isDarkMode
                                            ? [
                                          primaryColor,
                                          accentColor,
                                        ]
                                            : [
                                           Color(0xFF076BC5),
                                           Color(0xFF1889E4),
                                           Color(0xFF5AADEC),
                                           Color(0xFF9CC4E1),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(32),
                                        bottomLeft: Radius.circular(32),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: 1),
                                          duration: const Duration(milliseconds: 800),
                                          curve: Curves.elasticOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Transform.rotate(
                                                angle: (1 - value) * 2 * pi,
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.2),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    isDarkMode
                                                        ? 'assets/icons/light.png'
                                                        : 'assets/icons/dark.png',
                                                    width: 144,
                                                    height: 144,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: 1),
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Opacity(
                                              opacity: value,

                                              child: Transform.translate(
                                                offset: Offset(0, 20 * (1 - value)),
                                                child: Text(
                                                  S.of(context).loginTitle,
                                                  style:  TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: isArabic ? 'Droid sans arabic' : 'Roboto',
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Form Section
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // Email Field
                                          MouseRegion(
                                            onEnter: (_) => setState(() => _isEmailHovered = true),
                                            onExit: (_) => setState(() => _isEmailHovered = false),
                                            cursor: SystemMouseCursors.text,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              transform: Matrix4.identity()
                                                ..scale(_isEmailHovered ? 1.02 : 1.0),
                                              child: Focus(
                                                onFocusChange: (hasFocus) {
                                                  setState(() => _isEmailFocused = hasFocus);
                                                  if (hasFocus) {
                                                    _rippleController.forward(from: 0);
                                                  }
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    boxShadow: _isEmailFocused || _isEmailHovered
                                                        ? [
                                                      BoxShadow(
                                                        color: primaryColor.withOpacity(0.3),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                        : [],
                                                  ),
                                                  child: TextFormField(
                                                    controller: emailController,
                                                    keyboardType: TextInputType.emailAddress,
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : Colors.black87,
                                                      fontSize: 16,
                                                    ),
                                                    decoration: InputDecoration(
                                                      labelText: S.of(context).emailLabel,
                                                      labelStyle: TextStyle(
                                                        color: _isEmailFocused
                                                            ? primaryColor
                                                            : Colors.grey,
                                                      ),
                                                      prefixIcon: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 300),
                                                        margin: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          gradient: _isEmailFocused
                                                              ? LinearGradient(
                                                            colors: [primaryColor, accentColor],
                                                          )
                                                              : null,
                                                          color: _isEmailFocused
                                                              ? null
                                                              : Colors.grey.shade300,
                                                        ),
                                                        child: Icon(
                                                          Icons.email_outlined,
                                                          color: _isEmailFocused
                                                              ? Colors.white
                                                              : Colors.grey.shade600,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      filled: true,
                                                      fillColor: isDarkMode
                                                          ? Colors.grey.shade800.withOpacity(0.5)
                                                          : Colors.grey.shade50,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide(
                                                          color: primaryColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    validator: (value) =>
                                                    (value == null || value.isEmpty)
                                                        ? S.of(context).emailEmptyError
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          // Password Field
                                          MouseRegion(
                                            onEnter: (_) =>
                                                setState(() => _isPasswordHovered = true),
                                            onExit: (_) =>
                                                setState(() => _isPasswordHovered = false),
                                            cursor: SystemMouseCursors.text,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              transform: Matrix4.identity()
                                                ..scale(_isPasswordHovered ? 1.02 : 1.0),
                                              child: Focus(
                                                onFocusChange: (hasFocus) {
                                                  setState(() => _isPasswordFocused = hasFocus);
                                                  if (hasFocus) {
                                                    _rippleController.forward(from: 0);
                                                  }
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    boxShadow: _isPasswordFocused || _isPasswordHovered
                                                        ? [
                                                      BoxShadow(
                                                        color: primaryColor.withOpacity(0.3),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                        : [],
                                                  ),
                                                  child: TextFormField(
                                                    controller: passwordController,
                                                    obscureText: _obscurePassword,
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : Colors.black87,
                                                      fontSize: 16,
                                                    ),
                                                    decoration: InputDecoration(
                                                      labelText: S.of(context).passwordLabel,
                                                      labelStyle: TextStyle(
                                                        color: _isPasswordFocused
                                                            ? primaryColor
                                                            : Colors.grey,
                                                      ),
                                                      prefixIcon: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 300),
                                                        margin: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          gradient: _isPasswordFocused
                                                              ? LinearGradient(
                                                            colors: [primaryColor, accentColor],
                                                          )
                                                              : null,
                                                          color: _isPasswordFocused
                                                              ? null
                                                              : Colors.grey.shade300,
                                                        ),
                                                        child: Icon(
                                                          Icons.lock_outline,
                                                          color: _isPasswordFocused
                                                              ? Colors.white
                                                              : Colors.grey.shade600,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      suffixIcon: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _obscurePassword = !_obscurePassword;
                                                            });
                                                            HapticFeedback.lightImpact();
                                                          },
                                                          child: Container(
                                                            margin: const EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.grey.shade300,
                                                            ),
                                                            child: Icon(
                                                              _obscurePassword
                                                                  ? Icons.visibility_off_outlined
                                                                  : Icons.visibility_outlined,
                                                              color: Colors.grey.shade600,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      filled: true,
                                                      fillColor: isDarkMode
                                                          ? Colors.grey.shade800.withOpacity(0.5)
                                                          : Colors.grey.shade50,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide(
                                                          color: primaryColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    validator: (value) =>
                                                    (value == null || value.isEmpty)
                                                        ? S.of(context).passwordEmptyError
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Error Message
                                          if (errorMessage != null) ...[
                                            const SizedBox(height: 12),
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0, end: 1),
                                              duration: const Duration(milliseconds: 400),
                                              builder: (context, value, child) {
                                                return Opacity(
                                                  opacity: value,
                                                  child: Transform.scale(
                                                    scale: value,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade50,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(
                                                          color: Colors.red.shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.error_outline,
                                                            color: Colors.red.shade700,
                                                            size: 24,
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              errorMessage!,
                                                              style: TextStyle(
                                                                color: Colors.red.shade700,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],

                                          const SizedBox(height: 24),

                                          // Login Button
                                          MouseRegion(
                                            onEnter: (_) =>
                                                setState(() => _isLoginButtonHovered = true),
                                            onExit: (_) =>
                                                setState(() => _isLoginButtonHovered = false),
                                            cursor: isLoading
                                                ? SystemMouseCursors.wait
                                                : SystemMouseCursors.click,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              transform: Matrix4.identity()
                                                ..scale(_isLoginButtonHovered ? 1.05 : 1.0)
                                                ..rotateZ(_isLoginButtonHovered ? -0.01 : 0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 60,
                                                child: ElevatedButton(
                                                  onPressed: isLoading
                                                      ? null
                                                      : () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      HapticFeedback.mediumImpact();
                                                      await handleLogin(isArabic);
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:!isDarkMode?Color(0xFF1889E4) :primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    elevation: _isLoginButtonHovered ? 8 : 4,
                                                    shadowColor: primaryColor.withOpacity(0.5),
                                                  ),
                                                  child: isLoading
                                                      ? const SizedBox(
                                                    height: 28,
                                                    width: 28,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                          Colors.white),
                                                    ),
                                                  )
                                                      : Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        S.of(context).loginButton,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      AnimatedContainer(
                                                        duration:
                                                        const Duration(milliseconds: 200),
                                                        transform: Matrix4.identity()
                                                          ..translate(
                                                              _isLoginButtonHovered
                                                                  ? 8.0
                                                                  : 0.0),
                                                        child: const Icon(
                                                          Icons.arrow_forward_rounded,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 32),

                                          // Theme and Language Toggles
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: isDarkMode
                                                  ? Colors.white.withOpacity(0.05)
                                                  : Colors.grey.shade100,
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.1),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildToggleButton(
                                                  icon: Icons.translate,
                                                  label: isArabic?'اللغة':'Language',
                                                  onPressed: () =>
                                                      localeProvider.toggleLocale(),
                                                  isDarkMode: isDarkMode,
                                                  primaryColor:!isDarkMode ? Color(0xFF1889E4) : primaryColor,
                                                ),
                                                const SizedBox(width: 16),
                                                _buildToggleButton(
                                                  icon: isDarkMode
                                                      ? Icons.light_mode
                                                      : Icons.dark_mode,
                                                  label: isArabic?'الوضع':'Theme',
                                                  onPressed: () => themeProvider.toggleTheme(),
                                                  isDarkMode: isDarkMode,
                                                  primaryColor: !isDarkMode ? Color(0xFF1889E4) :primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle Class
class Particle {
  double x;
  double y;
  double size;
  double speedY;
  double opacity;
  int lifetime;

  Particle()
      : x = Random().nextDouble() * 1000,
        y = Random().nextDouble() * 1000,
        size = Random().nextDouble() * 4 + 2,
        speedY = Random().nextDouble() * 2 + 0.5,
        opacity = Random().nextDouble() * 0.5 + 0.3,
        lifetime = 0;

  void update() {
    y -= speedY;
    lifetime++;
    if (lifetime > 100) {
      opacity -= 0.01;
      if (opacity < 0) opacity = 0;
    }
  }

  bool get isExpired => opacity <= 0 || y < -20;
}

// Ripple Painter
class RipplePainter extends CustomPainter {
  final double animation;
  final Color color;

  RipplePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = max(size.width, size.height) * 1.5;
    final radius = maxRadius * animation;
    final paint = Paint()
      ..color = color.withOpacity((1 - animation) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}