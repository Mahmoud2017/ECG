import 'package:supabase_flutter/supabase_flutter.dart';

/// Contact links from the single-row `socialLinks` table
/// (columns: phoneNo, whatsApp, faceBook, instagram, x, linkedIn, email).
class ContactLinks {
  const ContactLinks({this.phone, this.email, this.whatsApp, this.faceBook, this.instagram, this.linkedIn, this.twitter});

  final String? phone;
  final String? email;
  final String? whatsApp;
  final String? faceBook;
  final String? instagram;
  final String? linkedIn;
  final String? twitter;

  static String? _s(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  factory ContactLinks.fromJson(Map<String, dynamic> j) => ContactLinks(
        phone: _s(j['phoneNo']),
        email: _s(j['email']),
        whatsApp: _s(j['whatsApp']),
        faceBook: _s(j['faceBook']),
        instagram: _s(j['instagram']),
        linkedIn: _s(j['linkedIn']),
        twitter: _s(j['x']),
      );
}

class ContactRepository {
  ContactRepository(this._client);

  final SupabaseClient _client;

  /// contact_messages(id, created_at, user_id, full_name, email, message)
  Future<void> sendMessage({required String name, required String email, required String message}) =>
      _client.from('contact_messages').insert({
        'user_id': _client.auth.currentUser?.id,
        'full_name': name.trim(),
        'email': email.trim(),
        'message': message.trim(),
      });

  Future<ContactLinks> fetchLinks() async {
    final row = await _client.from('socialLinks').select().limit(1).maybeSingle();
    return row == null ? const ContactLinks() : ContactLinks.fromJson(row);
  }
}
