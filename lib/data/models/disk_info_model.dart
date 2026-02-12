import 'package:vdiskusage/domain/entities/disk_info.dart';

/// Data model for [DiskInfo] with parsing from /proc/mounts.
class DiskInfoModel {
  final String devicePath;
  final String mountPoint;
  final String fileSystem;
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;

  const DiskInfoModel({
    required this.devicePath,
    required this.mountPoint,
    required this.fileSystem,
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
  });

  /// Parses a line from /proc/mounts.
  /// Format: device mountpoint fstype options dump pass
  static DiskInfoModel? fromMountLine(String line) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;

    final device = parts[0];
    final mountPoint = parts[1];
    final fsType = parts[2];

    // Filter virtual filesystems
    if (_isVirtualFs(fsType) || _isVirtualDevice(device)) return null;

    return DiskInfoModel(
      devicePath: device,
      mountPoint: mountPoint,
      fileSystem: fsType,
      totalBytes: 0,
      usedBytes: 0,
      availableBytes: 0,
    );
  }

  /// Creates a copy with disk usage stats filled in.
  DiskInfoModel withStats({
    required int total,
    required int used,
    required int available,
  }) {
    return DiskInfoModel(
      devicePath: devicePath,
      mountPoint: mountPoint,
      fileSystem: fileSystem,
      totalBytes: total,
      usedBytes: used,
      availableBytes: available,
    );
  }

  /// Converts to domain entity.
  DiskInfo toEntity() {
    return DiskInfo(
      devicePath: devicePath,
      mountPoint: mountPoint,
      fileSystem: fileSystem,
      totalBytes: totalBytes,
      usedBytes: usedBytes,
      availableBytes: availableBytes,
    );
  }

  static bool _isVirtualFs(String fsType) {
    const virtual = {
      'proc', 'sysfs', 'devpts', 'tmpfs', 'cgroup', 'cgroup2',
      'pstore', 'securityfs', 'debugfs', 'hugetlbfs', 'mqueue',
      'fusectl', 'configfs', 'devtmpfs', 'binfmt_misc', 'autofs',
      'tracefs', 'efivarfs', 'bpf', 'nsfs', 'fuse.portal',
      'fuse.gvfsd-fuse', 'overlay', 'squashfs',
    };
    return virtual.contains(fsType);
  }

  static bool _isVirtualDevice(String device) {
    return device == 'none' ||
        device == 'udev' ||
        device == 'tmpfs' ||
        device == 'devpts' ||
        device.startsWith('systemd-') ||
        device.startsWith('cgroup');
  }
}
