import 'package:vdiskusage/domain/entities/disk_info.dart';

/// Abstract repository for disk/partition information.
abstract class DiskRepository {
  /// Returns a list of all mounted partitions with usage info.
  Future<List<DiskInfo>> getMountedDisks();

  /// Returns info for a specific mount point.
  Future<DiskInfo?> getDiskInfo(String mountPoint);
}
