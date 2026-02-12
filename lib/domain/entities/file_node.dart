import 'package:equatable/equatable.dart';
import 'file_category.dart';

/// Represents a file or directory node in the scan tree.
class FileNode extends Equatable {
  final String name;
  final String path;
  final int sizeInBytes;
  final bool isDirectory;
  final DateTime lastModified;
  final FileCategory category;
  final List<FileNode> children;
  final int fileCount;
  final int dirCount;

  const FileNode({
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.isDirectory,
    required this.lastModified,
    this.category = FileCategory.other,
    this.children = const [],
    this.fileCount = 0,
    this.dirCount = 0,
  });

  /// Total size including all children (useful for directories).
  int get totalSize {
    if (!isDirectory || children.isEmpty) return sizeInBytes;
    return children.fold(sizeInBytes, (sum, child) => sum + child.totalSize);
  }

  /// Percentage of this node relative to [parentSize].
  double percentageOf(int parentSize) {
    if (parentSize <= 0) return 0.0;
    return (totalSize / parentSize * 100).clamp(0.0, 100.0);
  }

  /// Returns a sorted copy (by size, descending) of children.
  List<FileNode> get childrenSortedBySize {
    final sorted = List<FileNode>.from(children);
    sorted.sort((a, b) => b.totalSize.compareTo(a.totalSize));
    return sorted;
  }

  /// Returns a copy with updated children.
  FileNode copyWith({
    String? name,
    String? path,
    int? sizeInBytes,
    bool? isDirectory,
    DateTime? lastModified,
    FileCategory? category,
    List<FileNode>? children,
    int? fileCount,
    int? dirCount,
  }) {
    return FileNode(
      name: name ?? this.name,
      path: path ?? this.path,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      isDirectory: isDirectory ?? this.isDirectory,
      lastModified: lastModified ?? this.lastModified,
      category: category ?? this.category,
      children: children ?? this.children,
      fileCount: fileCount ?? this.fileCount,
      dirCount: dirCount ?? this.dirCount,
    );
  }

  @override
  List<Object?> get props => [path, sizeInBytes, isDirectory];
}
