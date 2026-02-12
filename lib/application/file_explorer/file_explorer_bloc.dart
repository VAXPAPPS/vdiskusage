import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_event.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_state.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/repositories/scanner_repository.dart';

class FileExplorerBloc extends Bloc<FileExplorerEvent, FileExplorerState> {
  final ScannerRepository _scannerRepository;

  FileExplorerBloc({required ScannerRepository scannerRepository})
      : _scannerRepository = scannerRepository,
        super(const ExplorerInitial()) {
    on<LoadDirectory>(_onLoadDirectory);
    on<SortBy>(_onSortBy);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterBySize>(_onFilterBySize);
    on<SearchFiles>(_onSearchFiles);
    on<DeleteFile>(_onDeleteFile);
    on<OpenInFileManager>(_onOpenInFileManager);
  }

  Future<void> _onLoadDirectory(
    LoadDirectory event,
    Emitter<FileExplorerState> emit,
  ) async {
    emit(const ExplorerLoading());
    try {
      final scanResult = await _scannerRepository.getScanResult();
      if (scanResult == null) {
        emit(const ExplorerError(message: 'No scan results available'));
        return;
      }

      // Find the target node in the tree
      final targetNode = _findNode(scanResult, event.path) ?? scanResult;
      final children = targetNode.childrenSortedBySize;

      emit(ExplorerLoaded(
        nodes: children,
        filteredNodes: children,
        currentPath: event.path,
      ));
    } catch (e) {
      emit(ExplorerError(message: e.toString()));
    }
  }

  void _onSortBy(SortBy event, Emitter<FileExplorerState> emit) {
    final currentState = state;
    if (currentState is! ExplorerLoaded) return;

    final sorted = _sortNodes(currentState.filteredNodes, event.criteria);
    emit(currentState.copyWith(
      filteredNodes: sorted,
      sortCriteria: event.criteria,
    ));
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<FileExplorerState> emit,
  ) {
    final currentState = state;
    if (currentState is! ExplorerLoaded) return;

    final filtered = _applyFilters(
      currentState.nodes,
      category: event.category,
      minSize: currentState.filterMinSize,
      query: currentState.searchQuery,
    );

    final sorted = _sortNodes(filtered, currentState.sortCriteria);

    emit(currentState.copyWith(
      filteredNodes: sorted,
      filterCategory: event.category,
      clearCategoryFilter: event.category == null,
    ));
  }

  void _onFilterBySize(
    FilterBySize event,
    Emitter<FileExplorerState> emit,
  ) {
    final currentState = state;
    if (currentState is! ExplorerLoaded) return;

    final filtered = _applyFilters(
      currentState.nodes,
      category: currentState.filterCategory,
      minSize: event.minSizeBytes,
      query: currentState.searchQuery,
    );

    final sorted = _sortNodes(filtered, currentState.sortCriteria);

    emit(currentState.copyWith(
      filteredNodes: sorted,
      filterMinSize: event.minSizeBytes,
      clearSizeFilter: event.minSizeBytes == null,
    ));
  }

  void _onSearchFiles(SearchFiles event, Emitter<FileExplorerState> emit) {
    final currentState = state;
    if (currentState is! ExplorerLoaded) return;

    final filtered = _applyFilters(
      currentState.nodes,
      category: currentState.filterCategory,
      minSize: currentState.filterMinSize,
      query: event.query,
    );

    final sorted = _sortNodes(filtered, currentState.sortCriteria);

    emit(currentState.copyWith(
      filteredNodes: sorted,
      searchQuery: event.query,
    ));
  }

  Future<void> _onDeleteFile(
    DeleteFile event,
    Emitter<FileExplorerState> emit,
  ) async {
    try {
      final entity = FileSystemEntity.typeSync(event.path);
      if (entity == FileSystemEntityType.directory) {
        await Directory(event.path).delete(recursive: true);
      } else if (entity == FileSystemEntityType.file) {
        await File(event.path).delete();
      }

      // Reload current directory
      final currentState = state;
      if (currentState is ExplorerLoaded) {
        add(LoadDirectory(path: currentState.currentPath));
      }
    } catch (e) {
      emit(ExplorerError(message: 'Delete failed: $e'));
    }
  }

  Future<void> _onOpenInFileManager(
    OpenInFileManager event,
    Emitter<FileExplorerState> emit,
  ) async {
    try {
      await Process.run('xdg-open', [event.path]);
    } catch (_) {
      // Non-critical
    }
  }

  /// Finds a node in the tree by path.
  FileNode? _findNode(FileNode root, String path) {
    if (root.path == path) return root;
    for (final child in root.children) {
      final found = _findNode(child, path);
      if (found != null) return found;
    }
    return null;
  }

  /// Applies all filters to the node list.
  List<FileNode> _applyFilters(
    List<FileNode> nodes, {
    required dynamic category,
    required int? minSize,
    required String query,
  }) {
    var result = nodes;

    if (category != null) {
      result = result.where((n) {
        if (n.isDirectory) return true; // Always show directories
        return n.category == category;
      }).toList();
    }

    if (minSize != null && minSize > 0) {
      result = result.where((n) => n.totalSize >= minSize).toList();
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result
          .where((n) => n.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return result;
  }

  /// Sorts nodes by the given criteria.
  List<FileNode> _sortNodes(List<FileNode> nodes, SortCriteria criteria) {
    final sorted = List<FileNode>.from(nodes);
    switch (criteria) {
      case SortCriteria.sizeDesc:
        sorted.sort((a, b) => b.totalSize.compareTo(a.totalSize));
      case SortCriteria.sizeAsc:
        sorted.sort((a, b) => a.totalSize.compareTo(b.totalSize));
      case SortCriteria.nameAsc:
        sorted.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortCriteria.nameDesc:
        sorted.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SortCriteria.dateDesc:
        sorted.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      case SortCriteria.dateAsc:
        sorted.sort((a, b) => a.lastModified.compareTo(b.lastModified));
    }
    return sorted;
  }
}
