import 'package:equatable/equatable.dart';

/// public.profiles(id, created_at, full_name, email, phoneNo, "job-title", specialty, avatar_url).
/// `location` has no column there; it lives in the auth user's metadata.
class Profile extends Equatable {
  const Profile({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.location,
    this.avatarUrl,
    this.specialty,
    this.jobTitle,
  });

  final String id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final String? avatarUrl;
  final String? specialty;
  final String? jobTitle;

  String get initials {
    final parts = (fullName ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory Profile.fromJson(Map<String, dynamic> j, {String? location}) => Profile(
        id: j['id'] as String,
        fullName: j['full_name'] as String?,
        email: j['email'] as String?,
        phoneNumber: j['phoneNo'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        specialty: j['specialty'] as String?,
        jobTitle: j['job-title'] as String?,
        location: location,
      );

  Profile copyWith({String? location}) => Profile(
        id: id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        location: location ?? this.location,
        avatarUrl: avatarUrl,
        specialty: specialty,
        jobTitle: jobTitle,
      );

  @override
  List<Object?> get props => [id, fullName, email, phoneNumber, location, avatarUrl, specialty, jobTitle];
}
