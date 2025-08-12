// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(email) => "تم إرسال رابط إعادة التعيين إلى ${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appTitle": MessageLookupByLibrary.simpleMessage("لوحة تحكم سرعة التسويق"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "emailEmptyError": MessageLookupByLibrary.simpleMessage("أدخل البريد"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("نسيت كلمة المرور؟"),
    "loginButton": MessageLookupByLibrary.simpleMessage("دخول"),
    "loginTitle": MessageLookupByLibrary.simpleMessage("تسجيل دخول المسؤول"),
    "passwordEmptyError": MessageLookupByLibrary.simpleMessage(
      "أدخل كلمة المرور",
    ),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "resetEmailSent": m0,
    "resetPasswordContent": MessageLookupByLibrary.simpleMessage(
      "أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين:",
    ),
    "resetPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "إعادة تعيين كلمة المرور",
    ),
    "send": MessageLookupByLibrary.simpleMessage("إرسال"),
  };
}
