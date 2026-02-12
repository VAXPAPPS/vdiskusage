import 'dart:async';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';
import 'package:vdiskusage/infrastructure/services/isolate_scanner_service.dart';

/// Datasource that manages file scanning via Isolates.
class FileScannerDatasource {
  final IsolateScannerService _scannerService;

  FileScannerDatasource({IsolateScannerService? scannerService})
      : _scannerService = scannerService ?? IsolateScannerService();

  bool get isScanning => _scannerService.isScanning;

  /// Starts scanning and returns a stream of progress updates.
  Stream<ScanProgress> scan(String path, {int maxDepth = 256}) {
    return _scannerService.scan(path, maxDepth: maxDepth);
  }

  /// Returns the last scan result tree.
  FileNode? get lastResult => _scannerService.lastResult;

  /// Cancels the ongoing scan.
  void cancel() => _scannerService.cancel();
}
