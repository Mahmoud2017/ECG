import 'package:supabase_flutter/supabase_flutter.dart';

/// One titled section of the Terms or Privacy page.
class ContentSection {
  const ContentSection({required this.title, required this.body});

  final String title;
  final String body;
}

class ContentDoc {
  const ContentDoc({required this.sections, this.updatedAt});

  final List<ContentSection> sections;
  final DateTime? updatedAt;
}

class Faq {
  const Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.likeCount = 0,
    this.unlikeCount = 0,
  });

  final String id;
  final String question;
  final String answer;
  final int likeCount;
  final int unlikeCount;
}

/// Help-centre content. Table and column names verified against the live project:
///   terms(id, created_at, title, description, order)
///   privacyPolicy(id, created_at, title, description, order, is_active)
///   faq(id, created_at, title, description, like_count, unlike_count, order)
/// Content is English only (no locale column).
class ContentRepository {
  ContentRepository(this._client);

  final SupabaseClient _client;

  /// [kind] is 'terms' or 'privacy'.
  Future<ContentDoc> fetchDoc(String kind) async {
    final rows = kind == 'privacy'
        ? await _client.from('privacyPolicy').select('title, description, created_at').eq('is_active', true).order('order')
        : await _client.from('terms').select('title, description, created_at').order('order');
    DateTime? latest;
    for (final r in rows) {
      final d = DateTime.tryParse(r['created_at']?.toString() ?? '');
      if (d != null && (latest == null || d.isAfter(latest))) latest = d;
    }
    return ContentDoc(
      updatedAt: latest?.toLocal(),
      sections: [
        for (final r in rows)
          ContentSection(title: r['title'] as String? ?? '', body: r['description'] as String? ?? ''),
      ],
    );
  }

  Future<List<Faq>> fetchFaqs() async {
    final rows = await _client.from('faq').select('id, title, description, like_count, unlike_count').order('order');
    return [
      for (final r in rows)
        Faq(
          id: r['id'].toString(),
          question: r['title'] as String? ?? '',
          answer: r['description'] as String? ?? '',
          likeCount: (r['like_count'] as num?)?.toInt() ?? 0,
          unlikeCount: (r['unlike_count'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// The project has no vote table or RPC, so a vote writes the new counters to the faq row.
  Future<void> voteFaq(String faqId, {required int likes, required int unlikes}) =>
      _client.from('faq').update({'like_count': likes, 'unlike_count': unlikes}).eq('id', faqId);
}
