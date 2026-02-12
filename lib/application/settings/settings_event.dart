import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateExcludedDirs extends SettingsEvent {
  final List<String> excludedDirs;

  const UpdateExcludedDirs({required this.excludedDirs});

  @override
  List<Object?> get props => [excludedDirs];
}

class UpdateMaxDepth extends SettingsEvent {
  final int maxDepth;

  const UpdateMaxDepth({required this.maxDepth});

  @override
  List<Object?> get props => [maxDepth];
}

class ClearCache extends SettingsEvent {
  const ClearCache();
}
