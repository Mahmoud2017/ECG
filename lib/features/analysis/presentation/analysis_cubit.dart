import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/errors.dart';
import '../data/ecg_analysis.dart';
import '../data/ecg_analysis_repository.dart';
import '../data/patient.dart';
import '../data/patients_repository.dart';

enum AnalysisStatus { idle, running, success, failure }

class AnalysisState extends Equatable {
  const AnalysisState({this.status = AnalysisStatus.idle, this.patient, this.error});

  final AnalysisStatus status;
  final Patient? patient;
  final String? error;

  @override
  List<Object?> get props => [status, patient, error];
}

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit(this._analysis, this._patients) : super(const AnalysisState());

  final EcgAnalysisRepository _analysis;
  final PatientsRepository _patients;

  Future<void> run(AnalysisRequest request) async {
    emit(const AnalysisState(status: AnalysisStatus.running));
    try {
      final result = await _analysis.analyze(request);
      final patient = await _patients.create(request, result);
      emit(AnalysisState(status: AnalysisStatus.success, patient: patient));
    } catch (e) {
      emit(AnalysisState(status: AnalysisStatus.failure, error: errorKey(e)));
    }
  }

  void reset() => emit(const AnalysisState());
}
