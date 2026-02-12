import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_bloc.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_event.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_state.dart';
import 'package:vdiskusage/application/scanner/scanner_bloc.dart';
import 'package:vdiskusage/application/scanner/scanner_state.dart';
import 'package:vdiskusage/presentation/widgets/file_tree_item.dart';
import 'package:vdiskusage/presentation/widgets/search_filter_bar.dart';

class FileExplorerScreen extends StatelessWidget {
  const FileExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, scannerState) {
        return BlocBuilder<FileExplorerBloc, FileExplorerState>(
          builder: (context, explorerState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File Explorer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Browse scan results with sorting and filtering',
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

                  // Check if we have scan data
                  if (scannerState is! ScannerCompleted)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_off_rounded,
                              size: 64,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Run a scan first to explore files',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Load scan data if not loaded yet
                    Builder(
                      builder: (context) {
                        if (explorerState is ExplorerInitial) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<FileExplorerBloc>().add(
                                  LoadDirectory(
                                    path: scannerState.currentNode.path,
                                  ),
                                );
                          });
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Filters
                    if (explorerState is ExplorerLoaded)
                      SearchFilterBar(
                        searchQuery: explorerState.searchQuery,
                        sortCriteria: explorerState.sortCriteria,
                        filterCategory: explorerState.filterCategory,
                        onSearch: (q) => context
                            .read<FileExplorerBloc>()
                            .add(SearchFiles(query: q)),
                        onSort: (s) => context
                            .read<FileExplorerBloc>()
                            .add(SortBy(criteria: s)),
                        onFilterCategory: (c) => context
                            .read<FileExplorerBloc>()
                            .add(FilterByCategory(category: c)),
                      ),
                    const SizedBox(height: 12),

                    // Column headers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Size',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Text(
                              'Bytes',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 56),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                    ),

                    // File list
                    Expanded(
                      child: _buildFileList(context, explorerState),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFileList(BuildContext context, FileExplorerState state) {
    if (state is ExplorerLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white54,
          strokeWidth: 2,
        ),
      );
    }

    if (state is ExplorerLoaded) {
      final nodes = state.filteredNodes;
      if (nodes.isEmpty) {
        return Center(
          child: Text(
            state.searchQuery.isNotEmpty
                ? 'No matching files found'
                : 'Empty directory',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        );
      }

      final parentSize = nodes.fold<int>(
        0,
        (sum, n) => sum + n.totalSize,
      );

      return ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          return FileTreeItem(
            node: node,
            parentSize: parentSize,
            onDoubleTap: node.isDirectory
                ? () {
                    context.read<FileExplorerBloc>().add(
                          LoadDirectory(path: node.path),
                        );
                  }
                : null,
            onContextMenu: (n) {
              _showContextMenu(context, n);
            },
          );
        },
      );
    }

    if (state is ExplorerError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showContextMenu(BuildContext context, dynamic node) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (node.isDirectory)
              _menuItem(
                icon: Icons.folder_open_rounded,
                label: 'Open Directory',
                onTap: () {
                  Navigator.pop(context);
                  context.read<FileExplorerBloc>().add(
                        LoadDirectory(path: node.path),
                      );
                },
              ),
            _menuItem(
              icon: Icons.open_in_new_rounded,
              label: 'Open in File Manager',
              onTap: () {
                Navigator.pop(context);
                context.read<FileExplorerBloc>().add(
                      OpenInFileManager(
                        path: node.isDirectory
                            ? node.path
                            : File(node.path).parent.path,
                      ),
                    );
              },
            ),
            Divider(
              color: Colors.white.withOpacity(0.08),
              height: 8,
            ),
            _menuItem(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: const Color(0xFFEF5350),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, node.path, node.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    final c = color ?? Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: c.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: c.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String path, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<FileExplorerBloc>()
                  .add(DeleteFile(path: path));
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
