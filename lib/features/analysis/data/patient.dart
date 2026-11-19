import 'package:equatable/equatable.dart';

import 'ecg_analysis.dart';

/// public.patients(id, created_at, updated_at, doctor_id, patient_code, age, sex, notes).
///
/// The live table does not store analysis results (the shipped app used a mock AI),
/// so [analysis] and the recording settings are only present right after a run, in memory.
class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.patientCode,
    required this.age,
    required this.sex,
    required this.createdAt,
    this.notes,
    this.analysis,
    this.leadConfiguration,
    this.samplingRate,
  });

  final String id;
  final String patientCode;
  final int age;
  final String sex; // male | female | other
  final String? notes;
  final DateTime createdAt;
  final EcgAnalysis? analysis;
  final String? leadConfiguration;
  final int? samplingRate;

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
        id: j['id'].toString(),
        patientCode: j['patient_code'] as String? ?? '',
        age: (j['age'] as num?)?.toInt() ?? 0,
        sex: (j['sex'] as String?)?.toLowerCase() ?? 'other',
        notes: j['notes'] as String?,
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );

  static Map<String, dynamic> insertJson(AnalysisRequest r, String doctorId) => {
        'doctor_id': doctorId,
        'patient_code': r.patientCode,
        'age': r.age,
        'sex': r.sex,
        'notes': r.notes,
      };

  Patient withRun(AnalysisRequest r, EcgAnalysis a) => Patient(
        id: id,
        patientCode: patientCode,
        age: age,
        sex: sex,
        notes: notes,
        createdAt: createdAt,
        analysis: a,
        leadConfiguration: r.leadConfiguration,
        samplingRate: r.samplingRate,
      );

  @override
  List<Object?> get props => [id, patientCode, createdAt, analysis];
}
