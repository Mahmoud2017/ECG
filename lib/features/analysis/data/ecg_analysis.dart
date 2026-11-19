import 'package:equatable/equatable.dart';

enum Severity { normal, borderline, abnormal }

Severity severityFrom(String? v) =>
    Severity.values.firstWhere((s) => s.name == v, orElse: () => Severity.normal);

/// Input to an analysis run.
class AnalysisRequest {
  const AnalysisRequest({
    required this.filePath,
    required this.patientCode,
    required this.age,
    required this.sex,
    required this.leadConfiguration,
    required this.samplingRate,
    this.notes,
  });

  final String filePath;
  final String patientCode;
  final int age;
  final String sex; // male | female | other
  final String leadConfiguration;
  final int samplingRate;
  final String? notes;
}

/// AI output for one ECG.
class EcgAnalysis extends Equatable {
  const EcgAnalysis({
    required this.severity,
    required this.heartRate,
    required this.prInterval,
    required this.qrsDuration,
    required this.qtcInterval,
    required this.findings,
    required this.summary,
    required this.confidence,
    required this.engine,
  });

  final Severity severity;
  final int heartRate; // bpm
  final int prInterval; // ms
  final int qrsDuration; // ms
  final int qtcInterval; // ms
  final List<String> findings;
  final String summary;
  final double confidence; // 0..1
  final String engine;

  Map<String, dynamic> toJson() => {
        'severity': severity.name,
        'heart_rate': heartRate,
        'pr_interval': prInterval,
        'qrs_duration': qrsDuration,
        'qtc_interval': qtcInterval,
        'findings': findings,
        'summary': summary,
        'confidence': confidence,
        'engine': engine,
      };

  factory EcgAnalysis.fromJson(Map<String, dynamic> j) => EcgAnalysis(
        severity: severityFrom(j['severity'] as String?),
        heartRate: (j['heart_rate'] as num?)?.toInt() ?? 0,
        prInterval: (j['pr_interval'] as num?)?.toInt() ?? 0,
        qrsDuration: (j['qrs_duration'] as num?)?.toInt() ?? 0,
        qtcInterval: (j['qtc_interval'] as num?)?.toInt() ?? 0,
        findings: (j['findings'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        summary: j['summary'] as String? ?? '',
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
        engine: j['engine'] as String? ?? '',
      );

  @override
  List<Object?> get props => [severity, heartRate, prInterval, qrsDuration, qtcInterval, findings, summary, confidence, engine];
}
