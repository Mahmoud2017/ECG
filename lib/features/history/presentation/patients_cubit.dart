import '../../../core/state/load_cubit.dart';
import '../../analysis/data/patient.dart';
import '../../analysis/data/patients_repository.dart';

/// All analysed patients for the signed-in doctor (newest first).
/// Shared by Home (stats + recent) and History.
class PatientsCubit extends LoadCubit<List<Patient>> {
  PatientsCubit(PatientsRepository repo) : super(() => repo.list());
}
