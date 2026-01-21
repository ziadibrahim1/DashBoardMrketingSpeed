// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لوحة تحكم سرعة التسويق';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailEmptyError => 'أدخل البريد';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordEmptyError => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordContent => 'أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين:';

  @override
  String get cancel => 'إلغاء';

  @override
  String get send => 'إرسال';

  @override
  String resetEmailSent(Object email) {
    return 'تم إرسال رابط إعادة التعيين إلى $email';
  }

  @override
  String get loginButton => 'دخول';
}
