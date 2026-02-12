import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:vdiskusage/core/consts/app_constants.dart';

/// Simple file-based cache for scan results.
class CacheService {
  String? _cacheDir;

  Future<String> get _cachePath async {
    if (_cacheDir == null) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      _cacheDir = p.join(home, AppConstants.cacheDirectoryName);
      await Directory(_cacheDir!).create(recursive: true);
    }
    return _cacheDir!;
  }

  /// Generates a cache key from a path.
  String _keyFromPath(String scanPath) {
    return scanPath.replaceAll('/', '_').replaceAll(' ', '_');
  }

  /// Saves scan data to cache as JSON.
  Future<void> save(String scanPath, Map<String, dynamic> data) async {
    try {
      final dir = await _cachePath;
      final file = File(p.join(dir, '${_keyFromPath(scanPath)}.json'));
      final envelope = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'path': scanPath,
        'data': data,
      };
      await file.writeAsString(jsonEncode(envelope));
    } catch (_) {
      // Cache write failure is non-critical
    }
  }

  /// Loads cached scan data. Returns null if expired or not found.
  Future<Map<String, dynamic>?> load(String scanPath) async {
    try {
      final dir = await _cachePath;
      final file = File(p.join(dir, '${_keyFromPath(scanPath)}.json'));

      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final envelope = jsonDecode(content) as Map<String, dynamic>;
      final timestamp = envelope['timestamp'] as int;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check expiry
      if (DateTime.now().difference(cachedTime) > AppConstants.cacheExpiry) {
        await file.delete();
        return null;
      }

      return envelope['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clears all cached data.
  Future<void> clearAll() async {
    try {
      final dir = await _cachePath;
      final directory = Directory(dir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
    } catch (_) {
      // Non-critical
    }
  }

  /// Returns total cache size in bytes.
  Future<int> getCacheSize() async {
    try {
      final dir = await _cachePath;
      final directory = Directory(dir);
      if (!await directory.exists()) return 0;

      int totalSize = 0;
      await for (final entity in directory.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (_) {
      return 0;
    }
  }
}
