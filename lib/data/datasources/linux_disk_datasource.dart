import 'dart:io';
import 'package:vdiskusage/data/models/disk_info_model.dart';

/// Reads disk/partition information from Linux system files.
class LinuxDiskDatasource {
  /// Reads /proc/mounts and returns parsed mount entries.
  Future<List<DiskInfoModel>> getMounts() async {
    try {
      final content = await File('/proc/mounts').readAsString();
      final lines = content.split('\n').where((l) => l.trim().isNotEmpty);

      final mounts = <DiskInfoModel>[];
      final seenDevices = <String>{};

      for (final line in lines) {
        final model = DiskInfoModel.fromMountLine(line);
        if (model != null && !seenDevices.contains(model.devicePath)) {
          seenDevices.add(model.devicePath);
          mounts.add(model);
        }
      }

      return mounts;
    } catch (e) {
      return [];
    }
  }

  /// Gets disk usage stats using statvfs via dart:io.
  Future<DiskInfoModel?> getStatsForMount(DiskInfoModel mount) async {
    try {
      final result = await Process.run('df', ['-B1', mount.mountPoint]);
      if (result.exitCode != 0) return null;

      final lines = (result.stdout as String).split('\n');
      if (lines.length < 2) return null;

      // Parse df output: Filesystem 1B-blocks Used Available Use% Mounted
      final parts = lines[1].split(RegExp(r'\s+'));
      if (parts.length < 4) return null;

      final total = int.tryParse(parts[1]) ?? 0;
      final used = int.tryParse(parts[2]) ?? 0;
      final available = int.tryParse(parts[3]) ?? 0;

      return mount.withStats(total: total, used: used, available: available);
    } catch (_) {
      return null;
    }
  }
}
