import 'package:equatable/equatable.dart';
import 'package:vdiskusage/domain/entities/file_category.dart';

abstract class FileExplorerEvent extends Equatable {
  const FileExplorerEvent();

  @override
  List<Object?> get props => [];
}

/// Load/display a directory from scan results.
class LoadDirectory extends FileExplorerEvent {
  final String path;

  const LoadDirectory({required this.path});

  @override
  List<Object?> get props => [path];
}

/// Sort the current list.
class SortBy extends FileExplorerEvent {
  final SortCriteria criteria;

  const SortBy({required this.criteria});

  @override
  List<Object?> get props => [criteria];
}

/// Filter by file category.
class FilterByCategory extends FileExplorerEvent {
  final FileCategory? category; // null = show all

  const FilterByCategory({this.category});

  @override
  List<Object?> get props => [category];
}

/// Filter by minimum size.
class FilterBySize extends FileExplorerEvent {
  final int? minSizeBytes; // null = no filter

  const FilterBySize({this.minSizeBytes});

  @override
  List<Object?> get props => [minSizeBytes];
}

/// Search by filename.
class SearchFiles extends FileExplorerEvent {
  final String query;

  const SearchFiles({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Delete a file or directory.
class DeleteFile extends FileExplorerEvent {
  final String path;

  const DeleteFile({required this.path});

  @override
  List<Object?> get props => [path];
}

/// Open path in system file manager.
class OpenInFileManager extends FileExplorerEvent {
  final String path;

  const OpenInFileManager({required this.path});

  @override
  List<Object?> get props => [path];
}

enum SortCriteria { sizeDesc, sizeAsc, nameAsc, nameDesc, dateDesc, dateAsc }
