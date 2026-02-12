import 'dart:async';
import 'package:vdiskusage/data/datasources/file_scanner_datasource.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';
import 'package:vdiskusage/domain/repositories/scanner_repository.dart';

/// Implementation of [ScannerRepository] using Isolate-based scanner.
class ScannerRepositoryImpl implements ScannerRepository {
  final FileScannerDatasource _datasource;

  ScannerRepositoryImpl({FileScannerDatasource? datasource})
      : _datasource = datasource ?? FileScannerDatasource();

  @override
  Stream<ScanProgress> scanDirectory(String path, {int maxDepth = 256}) {
    return _datasource.scan(path, maxDepth: maxDepth);
  }

  @override
  Future<FileNode?> getScanResult() async {
    return _datasource.lastResult;
  }

  @override
  void cancelScan() {
    _datasource.cancel();
  }

  @override
  bool get isScanning => _datasource.isScanning;
}
