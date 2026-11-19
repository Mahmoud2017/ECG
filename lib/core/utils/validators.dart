/// Form validators. Each returns an l10n key (translated by AppTextField) or null.
class Validators {
  Validators._();

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _phone = RegExp(r'^\+?[0-9 ]{7,15}$');

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'error_required' : null;

  static String? email(String? v) =>
      required(v) ?? (_email.hasMatch(v!.trim()) ? null : 'error_email');

  static String? phone(String? v) =>
      required(v) ?? (_phone.hasMatch(v!.trim()) ? null : 'error_phone');

  static String? password(String? v) =>
      required(v) ?? (v!.length < 6 ? 'error_password_short' : null);

  static String? Function(String?) confirm(String Function() other) =>
      (v) => required(v) ?? (v != other() ? 'error_password_match' : null);

  static String? name(String? v) {
    final t = v?.trim() ?? '';
    return (t.length < 2 || t.length > 120) ? 'error_name' : null;
  }

  static String? message(String? v) {
    final t = v?.trim() ?? '';
    return (t.length < 5 || t.length > 5000) ? 'error_message' : null;
  }

  static String? age(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < 0 || n > 130) ? 'error_age' : null;
  }

  static String? patientCode(String? v) =>
      required(v) ?? (v!.trim().length > 40 ? 'error_patient_code' : null);
}
