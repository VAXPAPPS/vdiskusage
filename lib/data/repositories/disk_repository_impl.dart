import 'package:vdiskusage/data/datasources/linux_disk_datasource.dart';
import 'package:vdiskusage/domain/entities/disk_info.dart';
import 'package:vdiskusage/domain/repositories/disk_repository.dart';

/// Implementation of [DiskRepository] for Linux.
class DiskRepositoryImpl implements DiskRepository {
  final LinuxDiskDatasource _datasource;

  DiskRepositoryImpl({LinuxDiskDatasource? datasource})
      : _datasource = datasource ?? LinuxDiskDatasource();

  @override
  Future<List<DiskInfo>> getMountedDisks() async {
    final mounts = await _datasource.getMounts();

    final disks = <DiskInfo>[];
    for (final mount in mounts) {
      final withStats = await _datasource.getStatsForMount(mount);
      if (withStats != null && withStats.totalBytes > 0) {
        disks.add(withStats.toEntity());
      }
    }

    // Sort by mount point for consistent display
    disks.sort((a, b) => a.mountPoint.compareTo(b.mountPoint));
    return disks;
  }

  @override
  Future<DiskInfo?> getDiskInfo(String mountPoint) async {
    final disks = await getMountedDisks();
    try {
      return disks.firstWhere((d) => d.mountPoint == mountPoint);
    } catch (_) {
      return null;
    }
  }
}
