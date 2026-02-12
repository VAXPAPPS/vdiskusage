import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';

/// Abstract repository for scanning directories.
abstract class ScannerRepository {
  /// Scans a directory and emits progress updates.
  Stream<ScanProgress> scanDirectory(String path, {int maxDepth});

  /// Returns the final scan result (call after scan completes).
  Future<FileNode?> getScanResult();

  /// Cancels the current scan operation.
  void cancelScan();

  /// Returns true if a scan is currently running.
  bool get isScanning;
}
