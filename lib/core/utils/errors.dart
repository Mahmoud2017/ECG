import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Text fragments that mean the request never reached the server, whatever wrapper
/// (ClientException, PostgrestException, AuthRetryableFetchException…) the client put around it.
const _networkSignatures = [
  'socketexception',
  'clientexception',
  'failed host lookup',
  'connection refused',
  'connection reset',
  'connection closed',
  'network is unreachable',
  'timed out',
  'timeoutexception',
  'handshakeexception',
];

bool _looksLikeNetwork(Object e) {
  final s = e.toString().toLowerCase();
  return _networkSignatures.any(s.contains);
}

/// Maps any thrown error to an l10n key.
String errorKey(Object e) {
  if (kDebugMode) debugPrint('errorKey <- ${e.runtimeType}: $e');
  if (e is SocketException || e is HttpException || e is TimeoutException) return 'error_network';
  // Check before the typed branches: the client wraps transport failures in its own exceptions.
  if (_looksLikeNetwork(e)) return 'error_network';
  if (e is AuthWeakPasswordException) return 'weak_password';
  if (e is AuthSessionMissingException) return 'session_expired';
  if (e is AuthException) {
    final msg = e.message.toLowerCase();
    if (msg.contains('jwt') || msg.contains('expired')) return 'session_expired';
    return e.message; // shown raw (e.g. "Invalid login credentials")
  }
  return 'error_generic';
}
