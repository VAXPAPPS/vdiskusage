import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:vdiskusage/core/consts/app_constants.dart';
import 'package:vdiskusage/core/utils/file_type_helper.dart';

import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';

/// High-performance scanner service using Dart Isolates.
///
/// Runs the file system scan in a separate isolate to keep UI responsive.
/// Uses dart:io for scanning (FFI is used via NativeScanner separately).
class IsolateScannerService {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _commandPort;
  bool _isScanning = false;
  FileNode? _lastResult;

  bool get isScanning => _isScanning;
  FileNode? get lastResult => _lastResult;

  /// Scans a directory in a separate isolate, streaming progress updates.
  Stream<ScanProgress> scan(String path, {int maxDepth = 256}) {
    final controller = StreamController<ScanProgress>();

    _startIsolate(path, maxDepth, controller).catchError((e) {
      controller.addError(e);
      controller.close();
    });

    return controller.stream;
  }

  Future<void> _startIsolate(
    String path,
    int maxDepth,
    StreamController<ScanProgress> controller,
  ) async {
    cancel(); // Cancel any existing scan

    _receivePort = ReceivePort();
    _isScanning = true;

    final initMessage = _ScanRequest(
      path: path,
      maxDepth: maxDepth,
      sendPort: _receivePort!.sendPort,
      excludedPaths: AppConstants.defaultExcludedPaths,
    );

    _isolate = await Isolate.spawn(_scanIsolateEntry, initMessage);

    final stopwatch = Stopwatch()..start();

    _receivePort!.listen((message) {
      if (message is _ScanProgressMessage) {
        final progress = ScanProgress(
          scannedFiles: message.fileCount,
          scannedDirs: message.dirCount,
          totalSizeBytes: message.totalSize,
          currentPath: message.currentPath,
          elapsed: stopwatch.elapsed,
        );
        controller.add(progress);
      } else if (message is _ScanCompleteMessage) {
        stopwatch.stop();
        _lastResult = message.rootNode;
        _isScanning = false;

        final finalProgress = ScanProgress(
          scannedFiles: message.fileCount,
          scannedDirs: message.dirCount,
          totalSizeBytes: message.totalSize,
          currentPath: path,
          elapsed: stopwatch.elapsed,
          isComplete: true,
        );
        controller.add(finalProgress);
        controller.close();
        _cleanup();
      } else if (message is _ScanErrorMessage) {
        stopwatch.stop();
        _isScanning = false;
        controller.addError(Exception(message.error));
        controller.close();
        _cleanup();
      } else if (message is SendPort) {
        _commandPort = message;
      }
    });
  }

  /// Cancels the current scan.
  void cancel() {
    _commandPort?.send('cancel');
    _cleanup();
    _isScanning = false;
  }

  void _cleanup() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _commandPort = null;
  }

  /// The isolate entry point — runs the actual scan.
  static void _scanIsolateEntry(_ScanRequest request) {
    final commandPort = ReceivePort();
    request.sendPort.send(commandPort.sendPort);

    bool cancelled = false;
    commandPort.listen((message) {
      if (message == 'cancel') cancelled = true;
    });

    try {
      int fileCount = 0;
      int dirCount = 0;
      int totalSize = 0;
      int updateCounter = 0;

      FileNode scanDir(String dirPath, int depth) {
        if (cancelled || depth > request.maxDepth) {
          return FileNode(
            name: p.basename(dirPath),
            path: dirPath,
            sizeInBytes: 0,
            isDirectory: true,
            lastModified: DateTime.now(),
          );
        }

        final children = <FileNode>[];
        int dirSize = 0;
        int localFileCount = 0;
        int localDirCount = 0;

        try {
          final dir = Directory(dirPath);
          final entities = dir.listSync(followLinks: false);

          for (final entity in entities) {
            if (cancelled) break;

            final entityPath = entity.path;

            // Skip excluded paths
            if (request.excludedPaths.any((ex) => entityPath.startsWith(ex))) {
              continue;
            }

            try {
              final stat = entity.statSync();

              if (entity is Directory) {
                dirCount++;
                localDirCount++;
                final childNode = scanDir(entityPath, depth + 1);
                children.add(childNode);
                dirSize += childNode.totalSize;
              } else if (entity is File) {
                fileCount++;
                localFileCount++;
                final size = stat.size;
                totalSize += size;
                dirSize += size;

                children.add(FileNode(
                  name: p.basename(entityPath),
                  path: entityPath,
                  sizeInBytes: size,
                  isDirectory: false,
                  lastModified: stat.modified,
                  category: FileTypeHelper.categorize(entityPath),
                ));
              }
            } catch (_) {
              // Permission denied or other error — skip silently
              continue;
            }

            // Send progress updates periodically
            updateCounter++;
            if (updateCounter % 500 == 0) {
              request.sendPort.send(_ScanProgressMessage(
                fileCount: fileCount,
                dirCount: dirCount,
                totalSize: totalSize,
                currentPath: entityPath,
              ));
            }
          }
        } catch (_) {
          // Can't read directory — return empty
        }

        // Sort children by size descending for better display
        children.sort((a, b) => b.totalSize.compareTo(a.totalSize));

        return FileNode(
          name: p.basename(dirPath),
          path: dirPath,
          sizeInBytes: dirSize,
          isDirectory: true,
          lastModified: DateTime.now(),
          children: children,
          fileCount: localFileCount,
          dirCount: localDirCount,
        );
      }

      final rootNode = scanDir(request.path, 0);

      if (!cancelled) {
        request.sendPort.send(_ScanCompleteMessage(
          rootNode: rootNode,
          fileCount: fileCount,
          dirCount: dirCount,
          totalSize: totalSize,
        ));
      }
    } catch (e) {
      request.sendPort.send(_ScanErrorMessage(error: e.toString()));
    }
  }
}

// ── Internal message classes for Isolate communication ──

class _ScanRequest {
  final String path;
  final int maxDepth;
  final SendPort sendPort;
  final List<String> excludedPaths;

  const _ScanRequest({
    required this.path,
    required this.maxDepth,
    required this.sendPort,
    required this.excludedPaths,
  });
}

class _ScanProgressMessage {
  final int fileCount;
  final int dirCount;
  final int totalSize;
  final String currentPath;

  const _ScanProgressMessage({
    required this.fileCount,
    required this.dirCount,
    required this.totalSize,
    required this.currentPath,
  });
}

class _ScanCompleteMessage {
  final FileNode rootNode;
  final int fileCount;
  final int dirCount;
  final int totalSize;

  const _ScanCompleteMessage({
    required this.rootNode,
    required this.fileCount,
    required this.dirCount,
    required this.totalSize,
  });
}

class _ScanErrorMessage {
  final String error;
  const _ScanErrorMessage({required this.error});
}
