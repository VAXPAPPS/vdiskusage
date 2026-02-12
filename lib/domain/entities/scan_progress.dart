import 'package:equatable/equatable.dart';

/// Represents the progress of a directory scan operation.
class ScanProgress extends Equatable {
  final int scannedFiles;
  final int scannedDirs;
  final int totalSizeBytes;
  final String currentPath;
  final Duration elapsed;
  final bool isComplete;

  const ScanProgress({
    this.scannedFiles = 0,
    this.scannedDirs = 0,
    this.totalSizeBytes = 0,
    this.currentPath = '',
    this.elapsed = Duration.zero,
    this.isComplete = false,
  });

  /// Total items scanned.
  int get totalItems => scannedFiles + scannedDirs;

  /// Scan speed (items per second).
  double get itemsPerSecond {
    if (elapsed.inMilliseconds <= 0) return 0.0;
    return totalItems / (elapsed.inMilliseconds / 1000.0);
  }

  ScanProgress copyWith({
    int? scannedFiles,
    int? scannedDirs,
    int? totalSizeBytes,
    String? currentPath,
    Duration? elapsed,
    bool? isComplete,
  }) {
    return ScanProgress(
      scannedFiles: scannedFiles ?? this.scannedFiles,
      scannedDirs: scannedDirs ?? this.scannedDirs,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      currentPath: currentPath ?? this.currentPath,
      elapsed: elapsed ?? this.elapsed,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        scannedFiles,
        scannedDirs,
        totalSizeBytes,
        currentPath,
        isComplete,
      ];
}
