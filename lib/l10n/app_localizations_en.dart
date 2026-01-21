// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Marketing Speed Dashboard';

  @override
  String get loginTitle => 'Admin Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailEmptyError => 'Please enter email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordEmptyError => 'Please enter password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordContent => 'Enter your email to send reset link:';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String resetEmailSent(Object email) {
    return 'Reset link sent to $email';
  }

  @override
  String get loginButton => 'Login';
}
