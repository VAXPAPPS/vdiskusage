import 'package:flutter/material.dart';
import 'package:vdiskusage/core/utils/file_size_formatter.dart';
import 'package:vdiskusage/domain/entities/disk_info.dart';
import 'package:vdiskusage/presentation/widgets/circular_usage_indicator.dart';

/// Glassmorphic card displaying disk partition info.
class DiskUsageCard extends StatelessWidget {
  final DiskInfo disk;
  final VoidCallback? onScanPressed;

  const DiskUsageCard({
    super.key,
    required this.disk,
    this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storage_rounded,
                  color: _statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disk.mountPoint,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${disk.devicePath}  •  ${disk.fileSystem}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              CircularUsageIndicator(
                percentage: disk.usagePercentage,
                size: 52,
                strokeWidth: 4,
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Usage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: disk.usagePercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _StatChip(
                label: 'Used',
                value: FileSizeFormatter.format(disk.usedBytes),
                color: _statusColor,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Free',
                value: FileSizeFormatter.format(disk.availableBytes),
                color: Colors.white.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Total',
                value: FileSizeFormatter.format(disk.totalBytes),
                color: Colors.white.withOpacity(0.4),
              ),
              const Spacer(),
              // Scan button
              if (onScanPressed != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onScanPressed,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            size: 14,
                            color: _statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Scan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    if (disk.isCritical) return const Color(0xFFEF5350);
    if (disk.isWarning) return const Color(0xFFFFB74D);
    return const Color(0xFF66BB6A);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
