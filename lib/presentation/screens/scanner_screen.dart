import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/scanner/scanner_bloc.dart';
import 'package:vdiskusage/application/scanner/scanner_event.dart';
import 'package:vdiskusage/application/scanner/scanner_state.dart';
import 'package:vdiskusage/presentation/widgets/treemap_widget.dart';
import 'package:vdiskusage/presentation/widgets/scan_progress_widget.dart';
import 'package:vdiskusage/presentation/widgets/breadcrumb_bar.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pathController.text = Platform.environment['HOME'] ?? '/';
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.radar_rounded, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scanner',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Analyze disk usage with treemap visualization',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Path input + scan button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _pathController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter directory path...',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _startScan(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(context, state),
                ],
              ),
              const SizedBox(height: 16),

              // Breadcrumb
              if (state is ScannerCompleted)
                BreadcrumbBar(
                  items: state.breadcrumbs.map((n) => n.name).toList(),
                  onItemTap: (index) {
                    context
                        .read<ScannerBloc>()
                        .add(GoToBreadcrumb(index: index));
                  },
                  onBack: () {
                    context.read<ScannerBloc>().add(const GoBack());
                  },
                ),
              if (state is ScannerCompleted) const SizedBox(height: 12),

              // Main content
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, ScannerState state) {
    if (state is ScannerScanning) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.read<ScannerBloc>().add(const CancelScan()),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEF5350).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.stop_rounded, size: 16, color: Color(0xFFEF5350)),
                SizedBox(width: 6),
                Text(
                  'Stop',
                  style: TextStyle(
                    color: Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startScan(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF64B5F6).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF64B5F6).withOpacity(0.3),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.radar_rounded, size: 16, color: Color(0xFF64B5F6)),
              SizedBox(width: 6),
              Text(
                'Scan',
                style: TextStyle(
                  color: Color(0xFF64B5F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScannerState state) {
    if (state is ScannerInitial) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.radar_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a directory path and click Scan',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ScannerScanning) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ScanProgressWidget(
            progress: state.progress,
            onCancel: () =>
                context.read<ScannerBloc>().add(const CancelScan()),
          ),
        ),
      );
    }

    if (state is ScannerCompleted) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TreemapWidget(
          node: state.currentNode,
          onNodeDoubleTap: (index) {
            context
                .read<ScannerBloc>()
                .add(NavigateToNode(nodeIndex: index));
          },
        ),
      );
    }

    if (state is ScannerError) {
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _startScan(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _startScan(BuildContext context) {
    final path = _pathController.text.trim();
    if (path.isNotEmpty) {
      context.read<ScannerBloc>().add(StartScan(path: path));
    }
  }
}
