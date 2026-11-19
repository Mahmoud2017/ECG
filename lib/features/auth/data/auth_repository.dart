import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Auth wrapper.
/// Sign-up uses an email confirmation *link*; password reset uses a 6-digit email OTP
/// (recovered methods: signIn, signUp, sendResetCode, verifyRecoveryCode, updatePassword, signOut).
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;
  Session? get currentSession => _auth.currentSession;
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) =>
      _auth.signUp(
        email: email.trim(),
        password: password,
        // Copied into public.profiles by the handle_new_user trigger (see supabase/schema.sql).
        data: {'full_name': fullName.trim(), 'phoneNo': phone.trim()},
      );

  Future<void> sendResetCode(String email) => _auth.resetPasswordForEmail(email.trim());

  Future<void> verifyRecoveryCode({required String email, required String code}) =>
      _auth.verifyOTP(email: email.trim(), token: code, type: OtpType.recovery);

  Future<void> updatePassword(String password) =>
      _auth.updateUser(UserAttributes(password: password));

  Future<void> signOut() => _auth.signOut();
}
