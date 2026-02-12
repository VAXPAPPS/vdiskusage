import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/dashboard/dashboard_event.dart';
import 'package:vdiskusage/application/dashboard/dashboard_state.dart';
import 'package:vdiskusage/domain/repositories/disk_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DiskRepository _diskRepository;

  DashboardBloc({required DiskRepository diskRepository})
      : _diskRepository = diskRepository,
        super(const DashboardInitial()) {
    on<LoadDisks>(_onLoadDisks);
    on<RefreshDisks>(_onRefreshDisks);
  }

  Future<void> _onLoadDisks(
    LoadDisks event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final disks = await _diskRepository.getMountedDisks();
      emit(DashboardLoaded(disks: disks));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshDisks(
    RefreshDisks event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final disks = await _diskRepository.getMountedDisks();
      emit(DashboardLoaded(disks: disks));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
