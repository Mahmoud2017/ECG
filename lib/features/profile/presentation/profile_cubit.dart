import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/load_cubit.dart';
import '../../../core/utils/errors.dart';
import '../data/profile.dart';
import '../data/profile_repository.dart';

class ProfileCubit extends Cubit<LoadState<Profile>> {
  ProfileCubit(this._repo) : super(const LoadState<Profile>());

  final ProfileRepository _repo;

  Future<void> load() async {
    emit(LoadState(status: LoadStatus.loading, data: state.data));
    try {
      emit(LoadState(status: LoadStatus.success, data: await _repo.fetch().timeout(loadTimeout)));
    } catch (e) {
      emit(LoadState(status: LoadStatus.failure, data: state.data, error: errorKey(e)));
    }
  }

  Future<String?> updateLocation(String location) async {
    try {
      await _repo.updateLocation(location);
      final p = state.data;
      if (p != null) emit(LoadState(status: LoadStatus.success, data: p.copyWith(location: location)));
      return null;
    } catch (e) {
      return errorKey(e);
    }
  }

  void clear() => emit(const LoadState<Profile>());
}
