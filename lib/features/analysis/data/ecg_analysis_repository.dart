import 'dart:math';

import 'ecg_analysis.dart';

abstract class EcgAnalysisRepository {
  Future<EcgAnalysis> analyze(AnalysisRequest request);
}

/// The shipped release used a mock (class `MockEcgAnalysisRepository` is in the binary).
/// Findings/summary texts below are the exact strings recovered from it.
/// Replace with a real implementation (e.g. a Supabase Edge Function) when the model is ready.
class MockEcgAnalysisRepository implements EcgAnalysisRepository {
  final _rng = Random();

  @override
  Future<EcgAnalysis> analyze(AnalysisRequest request) async {
    await Future<void>.delayed(const Duration(seconds: 3));
    final abnormal = _rng.nextInt(3) == 0;
    if (!abnormal) {
      final hr = 62 + _rng.nextInt(30);
      return EcgAnalysis(
        severity: Severity.normal,
        heartRate: hr,
        prInterval: 140 + _rng.nextInt(40),
        qrsDuration: 80 + _rng.nextInt(20),
        qtcInterval: 390 + _rng.nextInt(40),
        findings: const ['Normal Sinus Rhythm', 'No significant arrhythmia detected'],
        summary: 'ECG within normal limits. No acute abnormality detected.',
        confidence: 0.9 + _rng.nextDouble() * 0.08,
        engine: 'CardioPulse AI (mock)',
      );
    }
    final borderline = _rng.nextBool();
    return EcgAnalysis(
      severity: borderline ? Severity.borderline : Severity.abnormal,
      heartRate: 101 + _rng.nextInt(25),
      prInterval: 150 + _rng.nextInt(40),
      qrsDuration: 90 + _rng.nextInt(25),
      qtcInterval: 440 + _rng.nextInt(40),
      findings: const ['Sinus Tachycardia', 'Non-specific ST-T wave changes'],
      summary: 'Findings suggest possible repolarisation abnormality. Clinical correlation recommended.',
      confidence: 0.75 + _rng.nextDouble() * 0.15,
      engine: 'CardioPulse AI (mock)',
    );
  }
}
