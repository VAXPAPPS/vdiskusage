import 'package:equatable/equatable.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_event.dart';
import 'package:vdiskusage/domain/entities/file_category.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';

abstract class FileExplorerState extends Equatable {
  const FileExplorerState();

  @override
  List<Object?> get props => [];
}

class ExplorerInitial extends FileExplorerState {
  const ExplorerInitial();
}

class ExplorerLoading extends FileExplorerState {
  const ExplorerLoading();
}

class ExplorerLoaded extends FileExplorerState {
  final List<FileNode> nodes;
  final List<FileNode> filteredNodes;
  final SortCriteria sortCriteria;
  final FileCategory? filterCategory;
  final int? filterMinSize;
  final String searchQuery;
  final String currentPath;

  const ExplorerLoaded({
    required this.nodes,
    required this.filteredNodes,
    this.sortCriteria = SortCriteria.sizeDesc,
    this.filterCategory,
    this.filterMinSize,
    this.searchQuery = '',
    this.currentPath = '',
  });

  ExplorerLoaded copyWith({
    List<FileNode>? nodes,
    List<FileNode>? filteredNodes,
    SortCriteria? sortCriteria,
    FileCategory? filterCategory,
    bool clearCategoryFilter = false,
    int? filterMinSize,
    bool clearSizeFilter = false,
    String? searchQuery,
    String? currentPath,
  }) {
    return ExplorerLoaded(
      nodes: nodes ?? this.nodes,
      filteredNodes: filteredNodes ?? this.filteredNodes,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      filterCategory:
          clearCategoryFilter ? null : (filterCategory ?? this.filterCategory),
      filterMinSize:
          clearSizeFilter ? null : (filterMinSize ?? this.filterMinSize),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPath: currentPath ?? this.currentPath,
    );
  }

  @override
  List<Object?> get props => [
        filteredNodes,
        sortCriteria,
        filterCategory,
        filterMinSize,
        searchQuery,
        currentPath,
      ];
}

class ExplorerError extends FileExplorerState {
  final String message;

  const ExplorerError({required this.message});

  @override
  List<Object?> get props => [message];
}
