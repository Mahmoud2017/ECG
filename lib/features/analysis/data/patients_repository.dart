import 'package:supabase_flutter/supabase_flutter.dart';

import 'ecg_analysis.dart';
import 'patient.dart';

class PatientsRepository {
  PatientsRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Patient>> list({int? limit}) async {
    final query = _client.from('patients').select().eq('doctor_id', _uid).order('created_at', ascending: false);
    final rows = await (limit == null ? query : query.limit(limit));
    return rows.map(Patient.fromJson).toList();
  }

  Future<int> count() async {
    final res = await _client.from('patients').select('id').eq('doctor_id', _uid).count(CountOption.exact);
    return res.count;
  }

  /// Saves the patient record; the analysis is attached in memory only (no result columns).
  Future<Patient> create(AnalysisRequest request, EcgAnalysis analysis) async {
    final row = await _client.from('patients').insert(Patient.insertJson(request, _uid)).select().single();
    return Patient.fromJson(row).withRun(request, analysis);
  }
}
