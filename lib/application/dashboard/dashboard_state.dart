import 'package:equatable/equatable.dart';
import 'package:vdiskusage/domain/entities/disk_info.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<DiskInfo> disks;

  const DashboardLoaded({required this.disks});

  @override
  List<Object?> get props => [disks];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
