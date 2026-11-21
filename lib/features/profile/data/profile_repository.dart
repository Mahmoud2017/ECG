import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

/// `patients.doctor_id` and `contact_messages.user_id` reference `profiles(id)`, so the
/// signed-in doctor needs a profiles row before either insert. Creates it from sign-up
/// metadata when missing; never overwrites an existing row. Best effort: if RLS forbids
/// the insert, the following insert surfaces the real error.
Future<void> ensureProfileRow(SupabaseClient client) async {
  final user = client.auth.currentUser;
  if (user == null) return;
  final meta = user.userMetadata ?? {};
  try {
    await client.from('profiles').upsert(
      {
        'id': user.id,
        'email': user.email,
        'full_name': meta['full_name'],
        'phoneNo': meta['phoneNo'] ?? meta['phone_number'],
      },
      onConflict: 'id',
      ignoreDuplicates: true,
    );
  } catch (_) {
    // See doc comment.
  }
}

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> fetch() async {
    final user = _client.auth.currentUser!;
    final meta = user.userMetadata ?? {};
    final location = meta['location'] as String?;
    var row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row == null) {
      await ensureProfileRow(_client);
      row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    }
    if (row != null) {
      return Profile.fromJson({...row, 'email': row['email'] ?? user.email}, location: location);
    }
    // Still no row (e.g. RLS blocks the insert): fall back to auth metadata.
    return Profile(
      id: user.id,
      email: user.email,
      fullName: meta['full_name'] as String?,
      phoneNumber: (meta['phoneNo'] ?? meta['phone_number']) as String?,
      location: location,
    );
  }

  /// `profiles` has no location column, so it is kept in the user's auth metadata.
  Future<void> updateLocation(String location) =>
      _client.auth.updateUser(UserAttributes(data: {'location': location}));
}
