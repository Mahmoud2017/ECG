import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> fetch() async {
    final user = _client.auth.currentUser!;
    final meta = user.userMetadata ?? {};
    final location = meta['location'] as String?;
    final row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row != null) {
      return Profile.fromJson({...row, 'email': row['email'] ?? user.email}, location: location);
    }
    // No profile row yet: fall back to what sign-up stored in auth metadata.
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
