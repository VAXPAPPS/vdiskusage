import 'package:vdiskusage/core/utils/file_type_helper.dart';
import 'package:vdiskusage/domain/entities/file_category.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';

/// Data model for [FileNode] with serialization support.
class FileNodeModel {
  final String name;
  final String path;
  final int sizeInBytes;
  final bool isDirectory;
  final int lastModifiedMs;
  final String categoryName;
  final List<FileNodeModel> children;
  final int fileCount;
  final int dirCount;

  const FileNodeModel({
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.isDirectory,
    required this.lastModifiedMs,
    this.categoryName = 'other',
    this.children = const [],
    this.fileCount = 0,
    this.dirCount = 0,
  });

  /// Creates from a file system scan entry (raw data).
  factory FileNodeModel.fromScanEntry({
    required String path,
    required String name,
    required int size,
    required bool isDir,
    required int mtimeSeconds,
  }) {
    return FileNodeModel(
      name: name,
      path: path,
      sizeInBytes: size,
      isDirectory: isDir,
      lastModifiedMs: mtimeSeconds * 1000,
      categoryName: isDir ? 'other' : FileTypeHelper.categorize(name).name,
    );
  }

  /// Converts to domain entity.
  FileNode toEntity() {
    return FileNode(
      name: name,
      path: path,
      sizeInBytes: sizeInBytes,
      isDirectory: isDirectory,
      lastModified: DateTime.fromMillisecondsSinceEpoch(lastModifiedMs),
      category: FileCategory.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => FileCategory.other,
      ),
      children: children.map((c) => c.toEntity()).toList(),
      fileCount: fileCount,
      dirCount: dirCount,
    );
  }

  /// Converts to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': sizeInBytes,
      'isDir': isDirectory,
      'mtime': lastModifiedMs,
      'cat': categoryName,
      'fc': fileCount,
      'dc': dirCount,
      'ch': children.map((c) => c.toJson()).toList(),
    };
  }

  /// Creates from cached JSON.
  factory FileNodeModel.fromJson(Map<String, dynamic> json) {
    return FileNodeModel(
      name: json['name'] as String,
      path: json['path'] as String,
      sizeInBytes: json['size'] as int,
      isDirectory: json['isDir'] as bool,
      lastModifiedMs: json['mtime'] as int,
      categoryName: json['cat'] as String? ?? 'other',
      fileCount: json['fc'] as int? ?? 0,
      dirCount: json['dc'] as int? ?? 0,
      children: (json['ch'] as List<dynamic>?)
              ?.map((c) =>
                  FileNodeModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
