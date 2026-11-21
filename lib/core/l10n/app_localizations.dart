import 'package:flutter/widgets.dart';

/// Map-based localizations (recovered: `AppLocalizations`, `_AppLocalizationsDelegate`,
/// extension `AppLocalizationsX.tr`). Keys and most texts were recovered verbatim from
/// the release binary. Entries marked `// ~` were not found in the binary and were rewritten.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  bool get isArabic => locale.languageCode == 'ar';

  String tr(String key) =>
      (_values[locale.languageCode] ?? _en)[key] ?? _en[key] ?? key;

  static const Map<String, Map<String, String>> _values = {'en': _en, 'ar': _ar};

  static const Map<String, String> _en = {
    // Common
    'app_name': 'CardioPulse MD',
    'hello': 'Hello,',
    'next': 'Next',
    'skip': 'Skip',
    'start': 'Start',
    'retry': 'Retry',
    'cancel': 'Cancel',
    'close': 'Close',
    'back': 'Back',
    'more': 'More',
    'save': 'Save',
    'remove': 'Remove',
    'got_it': 'Got it',
    'see_all': 'See all',
    'not_set': 'Not set',
    'no_content': 'Nothing here yet.',
    'coming_soon': 'Coming soon',
    'coming_soon_body': "We're still building this feature. It will be available in an upcoming update.",
    'hipaa': 'HIPAA Compliant',
    'last_updated': 'Last updated',

    // Errors
    'error_required': 'This field is required',
    'error_email': 'Enter a valid email',
    'error_phone': 'Enter a valid phone number',
    'error_password_short': 'Password must be at least 6 characters',
    'error_password_match': 'Passwords do not match',
    'error_name': 'Name must be between 2 and 120 characters',
    'error_message': 'Message must be between 5 and 5000 characters',
    'error_age': 'Age must be between 0 and 130',
    'error_patient_code': 'Max 40 characters', // ~
    'error_no_file': 'Please upload or scan an ECG first',
    'error_open_link': 'Could not open link', // ~
    'error_network': 'No internet connection',
    'error_generic': 'Something went wrong. Please try again.',
    'session_expired': 'Session expired.',
    'weak_password': 'Password must be at least 6 characters.',
    'offline_title': "You're offline",
    'offline_body': 'Check your Wi-Fi or mobile data, then try again.',
    'server_title': "Can't reach the server",
    'server_body': "You're connected, but our servers aren't responding. Please try again in a moment.",
    'error_title': 'Something went wrong',
    'error_generic_body': "We couldn't load this page. Please try again.",
    'try_again': 'Try again',
    'tip_wifi': 'Wi-Fi',
    'tip_data': 'Mobile data',
    'tip_airplane': 'Airplane mode off',

    // Onboarding
    'onboarding_1_title': 'Advanced ECG Analysis at Your Fingertips',
    'onboarding_1_body': 'Detect abnormalities early and get accurate results with advanced AI analysis.',
    'onboarding_2_title': 'AI-Powered ECG Interpretation',
    'onboarding_2_body': 'AI-Powered insights for faster, smarter, and more confident cardiac care.',
    'onboarding_3_title': 'Better Decisions Healthier Tomorrows',
    'onboarding_3_body': 'Empower healthcare professionals with reliable data, actionable insights, and improved patient outcomes.',
    'get_started': 'Get Started',

    // Auth
    'welcome_back': 'Welcome Back',
    'login': 'Login',
    'login_subtitle': 'Ready to step up your style? Log in now!',
    'email_address': 'Email Address',
    'email_hint': 'name@email.com',
    'password': 'Password',
    'forgot_password_q': 'Forgot Password?',
    'no_account': "Don't have an account?",
    'have_account': 'Already have an account?', // ~
    'sign_up': 'Sign up',
    'create_account': 'Create Your Account',
    'sign_up_subtitle': 'Your healthcare experience starts here. Sign up now!',
    'full_name': 'Full Name',
    'full_name_hint': 'Enter your full name',
    'phone_number': 'Phone Number',
    'confirm_password': 'Confirm Password',
    'or_continue_with': 'or continue with',
    'terms_notice': 'By logging, you agree to our',
    'and': 'and', // ~
    'confirm_email_title': 'Confirm your email',
    'confirm_email_body': 'We sent a confirmation link to your email. Confirm it, then log in.',
    'forgot_password_title': 'Forgot Password', // ~
    'forgot_password_subtitle': "Enter your email and we'll send you a code to reset your password.",
    'send_code': 'Send Code',
    'verify_title': 'Verify Your Email',
    'verify_subtitle': 'Enter the 6-digit code we sent to',
    'verify': 'Verify',
    'no_code': "Didn't receive the code?",
    'resend_code': 'Resend code', // ~
    'code_resent': 'A new code has been sent.',
    'reset_password_title': 'Create New Password',
    'reset_password_subtitle': 'Your new password must be at least 6 characters.', // ~
    'new_password': 'New Password',
    'save_password': 'Save Password',
    'password_updated': 'Password updated.',

    // Navigation
    'nav_home': 'Home',
    'nav_analysis': 'Analysis',
    'nav_history': 'History',
    'nav_settings': 'Settings',

    // Home
    'total_patients': 'Total patients',
    'recent_patients': 'Recent patients',
    'no_patients_yet': 'No analyses yet. Start your first one above.',
    'start_analysis_title': 'Upload or Scan 12-Lead ECG',
    'start_analysis_body': 'Upload or scan a 12-lead ECG and get AI insights in seconds.',
    'start_now': 'Start now',
    'new_ecg_analysis': 'New ECG Analysis',
    'today': 'Today',

    // Analysis
    'upload_title': 'New ECG analysis', // ~
    'upload_formats': 'Supports DICOM, PDF, High-Res JPEG/PNG, or XML device export',
    'browse_files': 'Browse Files',
    'file_ready': 'File ready for analysis', // ~
    'change_file': 'Change file', // ~
    'camera_scan': 'Camera',
    'camera_scan_sub': 'Scan paper ECG',
    'pacs_files': 'PACS / Files', // ~
    'pacs_files_sub': 'Hospital system',
    'direct_sync': 'Direct Sync',
    'direct_sync_sub': 'ECG device',
    'patient_details': 'Patient & measurement data', // ~
    'patient_code': 'Patient ID (anonymous)', // ~
    'auto_generate': 'Auto-generate ID',
    'age': 'Age',
    'biological_sex': 'Biological Sex',
    'sex_male': 'Male',
    'sex_female': 'Female',
    'sex_other': 'Other',
    'lead_configuration': 'Lead Configuration',
    'sampling_rate': 'Sampling rate / calibration', // ~
    'clinical_notes': 'Clinical notes',
    'notes_hint': 'Symptoms, medications… (optional)', // ~
    'run_analysis': 'Run AI Analysis', // ~
    'analyzing': 'Analyzing ECG, this may take a few seconds…', // ~

    // Result
    'analysis_result': 'Analysis Result',
    'severity_normal': 'Normal ECG',
    'severity_borderline': 'Borderline ECG',
    'severity_abnormal': 'Abnormal ECG',
    'heart_rate': 'Heart rate',
    'pr_interval': 'PR interval',
    'qrs_duration': 'QRS duration', // ~
    'qtc_interval': 'QTc interval', // ~
    'findings': 'Findings',
    'engine': 'Engine',
    'ai_disclaimer': 'AI interpretation is decision support only and must be reviewed by a qualified clinician.',

    // History
    'no_reports': 'No saved reports.', // ~
    'no_saved_analysis': 'The AI report for this patient was not saved. Run a new analysis to see results.',

    // Settings
    'settings': 'Settings',
    'language': 'Language',
    'lang_en': 'English',
    'lang_ar': 'Arabic',
    'dark_mode': 'Dark mode',
    'notifications': 'Notifications',
    'location': 'Location',
    'location_hint': 'e.g. Alexandria, Egypt', // ~
    'help': 'Help',
    'faq': 'FAQ', // ~
    'privacy_policy': 'Privacy Policy',
    'privacy_header_sub': 'How we collect, use and protect your data.',
    'terms_conditions': 'Terms & Conditions', // ~
    'terms_header_sub': 'Please read these terms carefully before using the app.',
    'log_out': 'Log out', // ~
    'log_out_confirm': 'Are you sure you want to log out?',
    'faq_helpful': 'Was this helpful?',
    'vote_thanks': 'Thanks for your feedback!',

    // Contact
    'contact_us': 'Contact Us',
    'get_in_touch': 'Get in touch',
    'contact_subtitle': "We'd love to hear from you. Our team is always here to help.",
    'send_message': 'Send a message',
    'message': 'Message',
    'message_hint': 'How can we help?',
    'send_message_btn': 'Send Message',
    'message_sent': 'Message sent. We will get back to you soon.',
    'follow_us': 'Follow Us',
    'phone': 'Phone',
    'whatsapp': 'WhatsApp',
    'email': 'Email',
  };

  static const Map<String, String> _ar = {
    'app_name': 'CardioPulse MD',
    'hello': 'مرحباً،',
    'next': 'التالي',
    'skip': 'تخطي',
    'start': 'ابدأ',
    'retry': 'إعادة المحاولة',
    'cancel': 'إلغاء',
    'close': 'إغلاق',
    'back': 'رجوع',
    'more': 'المزيد',
    'save': 'حفظ', // ~
    'remove': 'إزالة',
    'got_it': 'حسناً',
    'see_all': 'عرض الكل',
    'not_set': 'غير محدد',
    'no_content': 'لا يوجد محتوى بعد.',
    'coming_soon': 'قريباً',
    'coming_soon_body': 'ما زلنا نعمل على هذه الميزة، وستتوفر في تحديث قادم.',
    'hipaa': 'متوافق مع HIPAA',
    'last_updated': 'آخر تحديث',

    'error_required': 'هذا الحقل مطلوب',
    'error_email': 'أدخل بريداً إلكترونياً صحيحاً',
    'error_phone': 'أدخل رقم هاتف صحيحاً',
    'error_password_short': 'يجب ألا تقل كلمة المرور عن 6 أحرف',
    'error_password_match': 'كلمتا المرور غير متطابقتين',
    'error_name': 'يجب أن يكون الاسم بين 2 و120 حرفاً',
    'error_message': 'يجب أن تكون الرسالة بين 5 و5000 حرف',
    'error_age': 'يجب أن يكون العمر بين 0 و130',
    'error_patient_code': '40 حرفاً كحد أقصى',
    'error_no_file': 'يرجى رفع أو مسح تخطيط القلب أولاً',
    'error_open_link': 'تعذر فتح الرابط',
    'error_network': 'لا يوجد اتصال بالإنترنت',
    'error_generic': 'حدث خطأ ما. حاول مرة أخرى.',
    'session_expired': 'انتهت الجلسة. سجّل الدخول مرة أخرى.', // ~
    'weak_password': 'يجب ألا تقل كلمة المرور عن 6 أحرف.',
    'offline_title': 'أنت غير متصل بالإنترنت',
    'offline_body': 'تحقق من شبكة Wi-Fi أو بيانات الهاتف ثم حاول مرة أخرى.',
    'server_title': 'تعذر الوصول إلى الخادم',
    'server_body': 'أنت متصل بالإنترنت، لكن خوادمنا لا تستجيب حالياً. حاول مرة أخرى بعد قليل.',
    'error_title': 'حدث خطأ ما',
    'error_generic_body': 'تعذر تحميل هذه الصفحة. حاول مرة أخرى.',
    'try_again': 'حاول مرة أخرى',
    'tip_wifi': 'Wi-Fi',
    'tip_data': 'بيانات الهاتف',
    'tip_airplane': 'إيقاف وضع الطيران',

    'onboarding_1_title': 'تحليل متقدم لتخطيط القلب بين يديك', // ~
    'onboarding_1_body': 'اكتشف التغيرات غير الطبيعية مبكراً واحصل على نتائج دقيقة بتحليل الذكاء الاصطناعي.', // ~
    'onboarding_2_title': 'تفسير تخطيط القلب بالذكاء الاصطناعي', // ~
    'onboarding_2_body': 'رؤى مدعومة بالذكاء الاصطناعي لرعاية قلبية أسرع وأذكى وأكثر ثقة.', // ~
    'onboarding_3_title': 'قرارات أفضل لغدٍ أكثر صحة', // ~
    'onboarding_3_body': 'تمكين المختصين ببيانات موثوقة ورؤى عملية ونتائج أفضل للمرضى.', // ~
    'get_started': 'ابدأ',

    'welcome_back': 'مرحباً بعودتك',
    'login': 'تسجيل الدخول',
    'login_subtitle': 'سجّل الدخول للمتابعة',
    'email_address': 'البريد الإلكتروني',
    'email_hint': 'name@email.com',
    'password': 'كلمة المرور',
    'forgot_password_q': 'نسيت كلمة المرور؟',
    'no_account': 'ليس لديك حساب؟',
    'have_account': 'لديك حساب بالفعل؟',
    'sign_up': 'إنشاء حساب',
    'create_account': 'أنشئ حسابك',
    'sign_up_subtitle': 'تجربتك الصحية تبدأ هنا. سجّل الآن!',
    'full_name': 'الاسم الكامل',
    'full_name_hint': 'أدخل اسمك الكامل',
    'phone_number': 'رقم الهاتف',
    'confirm_password': 'تأكيد كلمة المرور',
    'or_continue_with': 'أو تابع باستخدام',
    'terms_notice': 'بتسجيل الدخول، أنت توافق على',
    'and': 'و',
    'confirm_email_title': 'أكّد بريدك الإلكتروني',
    'confirm_email_body': 'أرسلنا رابط تأكيد إلى بريدك. أكّده ثم سجّل الدخول.',
    'forgot_password_title': 'نسيت كلمة المرور؟',
    'forgot_password_subtitle': 'أدخل بريدك وسنرسل لك رمزاً لإعادة تعيين كلمة المرور.',
    'send_code': 'إرسال الرمز',
    'verify_title': 'تحقق من بريدك',
    'verify_subtitle': 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى',
    'verify': 'تحقق',
    'no_code': 'لم يصلك الرمز؟',
    'resend_code': 'إعادة إرسال الرمز',
    'code_resent': 'تم إرسال رمز جديد.',
    'reset_password_title': 'إنشاء كلمة مرور جديدة',
    'reset_password_subtitle': 'يجب ألا تقل كلمة المرور الجديدة عن 6 أحرف.', // ~
    'new_password': 'كلمة المرور الجديدة',
    'save_password': 'حفظ كلمة المرور',
    'password_updated': 'تم تحديث كلمة المرور.',

    'nav_home': 'الرئيسية',
    'nav_analysis': 'التحليل',
    'nav_history': 'السجل',
    'nav_settings': 'الإعدادات',

    'total_patients': 'إجمالي المرضى',
    'recent_patients': 'أحدث المرضى',
    'no_patients_yet': 'لا توجد تحليلات بعد. ابدأ أول تحليل.',
    'start_analysis_title': 'ارفع أو امسح تخطيط قلب 12 قطباً',
    'start_analysis_body': 'ارفع أو امسح تخطيط قلب بـ12 قطباً واحصل على نتائج الذكاء الاصطناعي.',
    'start_now': 'ابدأ الآن',
    'new_ecg_analysis': 'تحليل تخطيط قلب جديد',
    'today': 'اليوم',

    'upload_title': 'تحليل تخطيط قلب جديد',
    'upload_formats': 'يدعم DICOM و PDF و JPEG/PNG عالي الدقة أو ملفات XML',
    'browse_files': 'تصفح الملفات',
    'file_ready': 'الملف جاهز للتحليل',
    'change_file': 'تغيير الملف',
    'camera_scan': 'الكاميرا',
    'camera_scan_sub': 'مسح تخطيط ورقي',
    'pacs_files': 'PACS / ملفات',
    'pacs_files_sub': 'نظام المستشفى',
    'direct_sync': 'مزامنة مباشرة',
    'direct_sync_sub': 'جهاز ECG',
    'patient_details': 'بيانات المريض والقياس',
    'patient_code': 'رقم المريض (مجهول)',
    'auto_generate': 'توليد تلقائي',
    'age': 'العمر',
    'biological_sex': 'الجنس',
    'sex_male': 'ذكر', // ~
    'sex_female': 'أنثى',
    'sex_other': 'آخر', // ~
    'lead_configuration': 'إعداد الأقطاب',
    'sampling_rate': 'معدل التسجيل / المعايرة',
    'clinical_notes': 'ملاحظات سريرية',
    'notes_hint': 'الأعراض، الأدوية… (اختياري)',
    'run_analysis': 'تشغيل تحليل الذكاء الاصطناعي',
    'analyzing': 'جارٍ تحليل التخطيط، قد يستغرق ذلك بضع ثوانٍ…',

    'analysis_result': 'نتيجة التحليل',
    'severity_normal': 'تخطيط طبيعي',
    'severity_borderline': 'تخطيط حدّي',
    'severity_abnormal': 'تخطيط غير طبيعي',
    'heart_rate': 'معدل القلب',
    'pr_interval': 'فترة PR',
    'qrs_duration': 'مدة QRS',
    'qtc_interval': 'فترة QTc',
    'findings': 'النتائج',
    'engine': 'المحرك',
    'ai_disclaimer': 'تفسير الذكاء الاصطناعي أداة مساعدة فقط ويجب مراجعته من طبيب مختص.',

    'no_reports': 'لا توجد تقارير محفوظة.',
    'no_saved_analysis': 'لم يتم حفظ تقرير الذكاء الاصطناعي لهذا المريض. شغّل تحليلاً جديداً لعرض النتائج.',

    'settings': 'الإعدادات',
    'language': 'اللغة',
    'lang_en': 'الإنجليزية',
    'lang_ar': 'العربية',
    'dark_mode': 'الوضع الداكن',
    'notifications': 'الإشعارات',
    'location': 'الموقع',
    'location_hint': 'مثال: الإسكندرية، مصر',
    'help': 'المساعدة',
    'faq': 'الأسئلة الشائعة',
    'privacy_policy': 'سياسة الخصوصية',
    'privacy_header_sub': 'كيف نجمع بياناتك ونستخدمها ونحميها.',
    'terms_conditions': 'الشروط والأحكام',
    'terms_header_sub': 'يرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق.',
    'log_out': 'تسجيل الخروج',
    'log_out_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
    'faq_helpful': 'هل كان هذا مفيداً؟',
    'vote_thanks': 'شكراً على ملاحظاتك!',

    'contact_us': 'اتصل بنا',
    'get_in_touch': 'تواصل معنا',
    'contact_subtitle': 'يسعدنا سماعك. فريقنا دائماً هنا للمساعدة.',
    'send_message': 'أرسل رسالة',
    'message': 'الرسالة',
    'message_hint': 'كيف يمكننا مساعدتك؟',
    'send_message_btn': 'إرسال الرسالة',
    'message_sent': 'تم إرسال رسالتك. سنتواصل معك قريباً.',
    'follow_us': 'تابعنا',
    'phone': 'الهاتف',
    'whatsapp': 'واتساب',
    'email': 'البريد الإلكتروني',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
