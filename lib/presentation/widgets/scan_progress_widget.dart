import 'package:flutter/material.dart';
import 'package:vdiskusage/core/utils/file_size_formatter.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';

/// Animated scan progress display with stats.
class ScanProgressWidget extends StatelessWidget {
  final ScanProgress progress;
  final VoidCallback? onCancel;

  const ScanProgressWidget({
    super.key,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scanning animation
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Scanning...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Current path
          Text(
            progress.currentPath,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                icon: Icons.insert_drive_file_rounded,
                value: '${progress.scannedFiles}',
                label: 'Files',
              ),
              const SizedBox(width: 24),
              _StatItem(
                icon: Icons.folder_rounded,
                value: '${progress.scannedDirs}',
                label: 'Dirs',
              ),
              const SizedBox(width: 24),
              _StatItem(
                icon: Icons.data_usage_rounded,
                value: FileSizeFormatter.formatCompact(
                    progress.totalSizeBytes),
                label: 'Size',
              ),
              const SizedBox(width: 24),
              _StatItem(
                icon: Icons.speed_rounded,
                value: '${progress.itemsPerSecond.toInt()}/s',
                label: 'Speed',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cancel button
          if (onCancel != null)
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white54,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
