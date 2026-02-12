import 'package:flutter/material.dart';
import 'package:vdiskusage/domain/entities/file_category.dart';
import 'package:vdiskusage/core/consts/app_constants.dart';

/// Provides icons and colors for each [FileCategory].
class FileTypeIcons {
  FileTypeIcons._();

  static IconData icon(FileCategory category) {
    switch (category) {
      case FileCategory.images:
        return Icons.image_rounded;
      case FileCategory.videos:
        return Icons.movie_rounded;
      case FileCategory.audio:
        return Icons.music_note_rounded;
      case FileCategory.documents:
        return Icons.description_rounded;
      case FileCategory.archives:
        return Icons.archive_rounded;
      case FileCategory.code:
        return Icons.code_rounded;
      case FileCategory.system:
        return Icons.settings_rounded;
      case FileCategory.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color color(FileCategory category) {
    return AppConstants.categoryColors[category.name] ??
        const Color(0xFFAED581);
  }

  /// Icon for directory.
  static const IconData folderIcon = Icons.folder_rounded;
  static const Color folderColor = Color(0xFFFFCA28);

  /// Icon for symlink.
  static const IconData symlinkIcon = Icons.link_rounded;
  static const Color symlinkColor = Color(0xFF78909C);
}
