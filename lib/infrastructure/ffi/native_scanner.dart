import 'dart:ffi';
import 'dart:io' show File, Platform;
import 'package:ffi/ffi.dart';

/// FFI bindings for the native scanner library.
///
/// The native library provides high-performance file system scanning
/// using direct syscalls (lstat, opendir/readdir, statvfs).

// ── Struct definitions matching C structs ──

final class FileEntry extends Struct {
  @Array(4096)
  external Array<Uint8> pathBytes;

  @Int64()
  external int size;

  @Int64()
  external int mtime;

  @Int32()
  external int isDir;

  @Int32()
  external int depth;
}

final class ScanResult extends Opaque {}

final class DiskStats extends Struct {
  @Int64()
  external int totalBytes;

  @Int64()
  external int freeBytes;

  @Int64()
  external int availableBytes;

  @Int64()
  external int usedBytes;

  @Array(256)
  external Array<Uint8> filesystemBytes;

  @Array(4096)
  external Array<Uint8> mountPointBytes;

  @Array(4096)
  external Array<Uint8> deviceBytes;
}

// ── Function typedefs ──

typedef ScanDirectoryNative = Pointer<ScanResult> Function(
  Pointer<Utf8> path,
  Int32 maxDepth,
  Pointer<Int32> cancelFlag,
);
typedef ScanDirectoryDart = Pointer<ScanResult> Function(
  Pointer<Utf8> path,
  int maxDepth,
  Pointer<Int32> cancelFlag,
);

typedef ResultCountNative = Int32 Function(Pointer<ScanResult> result);
typedef ResultCountDart = int Function(Pointer<ScanResult> result);

typedef ResultTotalSizeNative = Int64 Function(Pointer<ScanResult> result);
typedef ResultTotalSizeDart = int Function(Pointer<ScanResult> result);

typedef ResultFileCountNative = Int32 Function(Pointer<ScanResult> result);
typedef ResultFileCountDart = int Function(Pointer<ScanResult> result);

typedef ResultDirCountNative = Int32 Function(Pointer<ScanResult> result);
typedef ResultDirCountDart = int Function(Pointer<ScanResult> result);

typedef ResultEntryAtNative = Pointer<FileEntry> Function(
  Pointer<ScanResult> result,
  Int32 index,
);
typedef ResultEntryAtDart = Pointer<FileEntry> Function(
  Pointer<ScanResult> result,
  int index,
);

typedef EntryPathNative = Pointer<Utf8> Function(Pointer<FileEntry> entry);
typedef EntryPathDart = Pointer<Utf8> Function(Pointer<FileEntry> entry);

typedef EntrySizeNative = Int64 Function(Pointer<FileEntry> entry);
typedef EntrySizeDart = int Function(Pointer<FileEntry> entry);

typedef EntryMtimeNative = Int64 Function(Pointer<FileEntry> entry);
typedef EntryMtimeDart = int Function(Pointer<FileEntry> entry);

typedef EntryIsDirNative = Int32 Function(Pointer<FileEntry> entry);
typedef EntryIsDirDart = int Function(Pointer<FileEntry> entry);

typedef EntryDepthNative = Int32 Function(Pointer<FileEntry> entry);
typedef EntryDepthDart = int Function(Pointer<FileEntry> entry);

typedef FreeScanResultNative = Void Function(Pointer<ScanResult> result);
typedef FreeScanResultDart = void Function(Pointer<ScanResult> result);

typedef GetDiskStatsNative = Int32 Function(
  Pointer<Utf8> path,
  Pointer<DiskStats> stats,
);
typedef GetDiskStatsDart = int Function(
  Pointer<Utf8> path,
  Pointer<DiskStats> stats,
);

typedef CreateCancelFlagNative = Pointer<Int32> Function();
typedef CreateCancelFlagDart = Pointer<Int32> Function();

typedef FreeCancelFlagNative = Void Function(Pointer<Int32> flag);
typedef FreeCancelFlagDart = void Function(Pointer<Int32> flag);

/// Wrapper around the native scanner FFI library.
class NativeScanner {
  late final DynamicLibrary _lib;
  bool _isLoaded = false;

  // Cached function lookups
  late final ScanDirectoryDart _scanDirectory;
  late final ResultCountDart _resultCount;
  late final ResultTotalSizeDart _resultTotalSize;
  late final ResultFileCountDart _resultFileCount;
  late final ResultDirCountDart _resultDirCount;
  late final ResultEntryAtDart _resultEntryAt;
  late final EntryPathDart _entryPath;
  late final EntrySizeDart _entrySize;
  late final EntryMtimeDart _entryMtime;
  late final EntryIsDirDart _entryIsDir;
  late final EntryDepthDart _entryDepth;
  late final FreeScanResultDart _freeScanResult;
  late final GetDiskStatsDart _getDiskStats;
  late final CreateCancelFlagDart _createCancelFlag;
  late final FreeCancelFlagDart _freeCancelFlag;

  NativeScanner() {
    _loadLibrary();
  }

  void _loadLibrary() {
    try {
      final libPath = _findLibraryPath();
      _lib = DynamicLibrary.open(libPath);
      _bindFunctions();
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
    }
  }

  String _findLibraryPath() {
    // Look in common locations
    final execDir = Platform.resolvedExecutable;
    final dir = execDir.substring(0, execDir.lastIndexOf('/'));
    final candidates = [
      '$dir/lib/libvenom_scanner.so',
      '$dir/libvenom_scanner.so',
      'libvenom_scanner.so',
    ];

    for (final path in candidates) {
      if (_fileExists(path)) return path;
    }

    return 'libvenom_scanner.so'; // Let DynamicLibrary.open handle the error
  }

  bool _fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  void _bindFunctions() {
    _scanDirectory = _lib
        .lookupFunction<ScanDirectoryNative, ScanDirectoryDart>(
            'scan_directory');
    _resultCount = _lib
        .lookupFunction<ResultCountNative, ResultCountDart>('result_count');
    _resultTotalSize = _lib
        .lookupFunction<ResultTotalSizeNative, ResultTotalSizeDart>(
            'result_total_size');
    _resultFileCount = _lib
        .lookupFunction<ResultFileCountNative, ResultFileCountDart>(
            'result_file_count');
    _resultDirCount = _lib
        .lookupFunction<ResultDirCountNative, ResultDirCountDart>(
            'result_dir_count');
    _resultEntryAt = _lib
        .lookupFunction<ResultEntryAtNative, ResultEntryAtDart>(
            'result_entry_at');
    _entryPath = _lib
        .lookupFunction<EntryPathNative, EntryPathDart>('entry_path');
    _entrySize = _lib
        .lookupFunction<EntrySizeNative, EntrySizeDart>('entry_size');
    _entryMtime = _lib
        .lookupFunction<EntryMtimeNative, EntryMtimeDart>('entry_mtime');
    _entryIsDir = _lib
        .lookupFunction<EntryIsDirNative, EntryIsDirDart>('entry_is_dir');
    _entryDepth = _lib
        .lookupFunction<EntryDepthNative, EntryDepthDart>('entry_depth');
    _freeScanResult = _lib
        .lookupFunction<FreeScanResultNative, FreeScanResultDart>(
            'free_scan_result');
    _getDiskStats = _lib
        .lookupFunction<GetDiskStatsNative, GetDiskStatsDart>('get_disk_stats');
    _createCancelFlag = _lib
        .lookupFunction<CreateCancelFlagNative, CreateCancelFlagDart>(
            'create_cancel_flag');
    _freeCancelFlag = _lib
        .lookupFunction<FreeCancelFlagNative, FreeCancelFlagDart>(
            'free_cancel_flag');
  }

  bool get isAvailable => _isLoaded;

  /// Creates a cancel flag that can be set to cancel a scan.
  Pointer<Int32> createCancelFlag() => _createCancelFlag();

  /// Frees a cancel flag.
  void freeCancelFlag(Pointer<Int32> flag) => _freeCancelFlag(flag);

  /// Scans a directory. Returns opaque ScanResult pointer.
  Pointer<ScanResult> scanDirectory(
    String path,
    int maxDepth,
    Pointer<Int32> cancelFlag,
  ) {
    final pathPtr = path.toNativeUtf8();
    try {
      return _scanDirectory(pathPtr, maxDepth, cancelFlag);
    } finally {
      calloc.free(pathPtr);
    }
  }

  int resultCount(Pointer<ScanResult> result) => _resultCount(result);
  int resultTotalSize(Pointer<ScanResult> result) => _resultTotalSize(result);
  int resultFileCount(Pointer<ScanResult> result) => _resultFileCount(result);
  int resultDirCount(Pointer<ScanResult> result) => _resultDirCount(result);

  /// Gets entry at index. Returns path, size, mtime, isDir, depth.
  ({String path, int size, int mtime, bool isDir, int depth}) getEntry(
    Pointer<ScanResult> result,
    int index,
  ) {
    final entry = _resultEntryAt(result, index);
    return (
      path: _entryPath(entry).toDartString(),
      size: _entrySize(entry),
      mtime: _entryMtime(entry),
      isDir: _entryIsDir(entry) != 0,
      depth: _entryDepth(entry),
    );
  }

  void freeScanResult(Pointer<ScanResult> result) => _freeScanResult(result);

  /// Gets disk stats for a mount point.
  ({int total, int free, int available, int used})? getDiskStats(String path) {
    final pathPtr = path.toNativeUtf8();
    final stats = calloc<DiskStats>();
    try {
      final ret = _getDiskStats(pathPtr, stats);
      if (ret != 0) return null;
      return (
        total: stats.ref.totalBytes,
        free: stats.ref.freeBytes,
        available: stats.ref.availableBytes,
        used: stats.ref.usedBytes,
      );
    } finally {
      calloc.free(pathPtr);
      calloc.free(stats);
    }
  }
}

