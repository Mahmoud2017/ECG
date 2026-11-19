import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/errors.dart';

/// Upper bound for any screen's initial load, so a dead backend ends in an error state.
const loadTimeout = Duration(seconds: 15);

enum LoadStatus { initial, loading, success, failure }

class LoadState<T> extends Equatable {
  const LoadState({this.status = LoadStatus.initial, this.data, this.error});

  final LoadStatus status;
  final T? data;
  final String? error; // l10n key

  bool get isLoading => status == LoadStatus.loading;

  @override
  List<Object?> get props => [status, data, error];
}

/// Generic "fetch something and show it" cubit.
class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit(this._loader) : super(LoadState<T>());

  final Future<T> Function() _loader;

  Future<void> load() async {
    emit(LoadState<T>(status: LoadStatus.loading, data: state.data));
    try {
      emit(LoadState<T>(status: LoadStatus.success, data: await _loader().timeout(loadTimeout)));
    } catch (e) {
      emit(LoadState<T>(status: LoadStatus.failure, data: state.data, error: errorKey(e)));
    }
  }

  void clear() => emit(LoadState<T>());
}
