import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final List<String> excludedDirs;
  final int maxDepth;
  final int cacheSizeBytes;

  const SettingsLoaded({
    required this.excludedDirs,
    required this.maxDepth,
    this.cacheSizeBytes = 0,
  });

  SettingsLoaded copyWith({
    List<String>? excludedDirs,
    int? maxDepth,
    int? cacheSizeBytes,
  }) {
    return SettingsLoaded(
      excludedDirs: excludedDirs ?? this.excludedDirs,
      maxDepth: maxDepth ?? this.maxDepth,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
    );
  }

  @override
  List<Object?> get props => [excludedDirs, maxDepth, cacheSizeBytes];
}
