import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../../core/utils/errors.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final User? user;

  @override
  List<Object?> get props => [status, user?.id];
}

/// Form-submission state used by the auth pages.
class AuthFormState {
  const AuthFormState({this.loading = false, this.error});

  final bool loading;
  final String? error;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState()) {
    _sub = _repo.authStateChanges.listen((_) => _sync());
  }

  final AuthRepository _repo;
  late final StreamSubscription<dynamic> _sub;

  bool _resolved = false;

  AuthRepository get repository => _repo;
  bool get isLoggedIn => _repo.currentUser != null;

  /// Called by the splash page when it leaves; until then the router does not redirect.
  void markResolved() {
    _resolved = true;
    _sync();
  }

  void _sync() {
    if (!_resolved) return;
    final user = _repo.currentUser;
    emit(AuthState(
      status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      user: user,
    ));
  }

  /// Runs [action] and returns an l10n error key, or null on success.
  Future<String?> run(Future<void> Function(AuthRepository repo) action) async {
    try {
      await action(_repo);
      return null;
    } catch (e) {
      return errorKey(e);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _sync();
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
