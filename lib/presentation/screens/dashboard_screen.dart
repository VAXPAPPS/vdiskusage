import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/dashboard/dashboard_bloc.dart';
import 'package:vdiskusage/application/dashboard/dashboard_event.dart';
import 'package:vdiskusage/application/dashboard/dashboard_state.dart';
import 'package:vdiskusage/application/scanner/scanner_bloc.dart';
import 'package:vdiskusage/application/scanner/scanner_event.dart';
import 'package:vdiskusage/presentation/widgets/disk_usage_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.dashboard_rounded,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Mounted partitions overview',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(const RefreshDisks());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoading || state is DashboardInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white54,
          strokeWidth: 2,
        ),
      );
    }

    if (state is DashboardError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded) {
      if (state.disks.isEmpty) {
        return const Center(
          child: Text(
            'No mounted partitions found',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900
              ? 3
              : constraints.maxWidth > 500
                  ? 2
                  : 1;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.disks.length,
            itemBuilder: (context, index) {
              final disk = state.disks[index];
              return DiskUsageCard(
                disk: disk,
                onScanPressed: () {
                  context.read<ScannerBloc>().add(
                        StartScan(path: disk.mountPoint),
                      );
                  // TODO: Navigate to scanner tab
                },
              );
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
