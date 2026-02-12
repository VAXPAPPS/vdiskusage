import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load all mounted disks.
class LoadDisks extends DashboardEvent {
  const LoadDisks();
}

/// Refresh disk information.
class RefreshDisks extends DashboardEvent {
  const RefreshDisks();
}
