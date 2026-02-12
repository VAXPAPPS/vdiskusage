import 'package:equatable/equatable.dart';

/// Represents information about a mounted disk/partition.
class DiskInfo extends Equatable {
  final String devicePath;
  final String mountPoint;
  final String fileSystem;
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;

  const DiskInfo({
    required this.devicePath,
    required this.mountPoint,
    required this.fileSystem,
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
  });

  /// Usage percentage (0.0 to 100.0).
  double get usagePercentage {
    if (totalBytes <= 0) return 0.0;
    return (usedBytes / totalBytes * 100).clamp(0.0, 100.0);
  }

  /// Free space percentage.
  double get freePercentage => 100.0 - usagePercentage;

  /// Returns true if the partition is almost full (>90%).
  bool get isCritical => usagePercentage > 90.0;

  /// Returns true if the partition is getting full (>75%).
  bool get isWarning => usagePercentage > 75.0;

  @override
  List<Object?> get props => [devicePath, mountPoint, totalBytes, usedBytes];
}
