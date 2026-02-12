import 'package:path/path.dart' as p;
import 'package:vdiskusage/domain/entities/file_category.dart';

/// Maps file extensions to [FileCategory].
class FileTypeHelper {
  FileTypeHelper._();

  static const Map<String, FileCategory> _extensionMap = {
    // Images
    '.jpg': FileCategory.images, '.jpeg': FileCategory.images,
    '.png': FileCategory.images, '.gif': FileCategory.images,
    '.bmp': FileCategory.images, '.svg': FileCategory.images,
    '.webp': FileCategory.images, '.ico': FileCategory.images,
    '.tiff': FileCategory.images, '.raw': FileCategory.images,

    // Videos
    '.mp4': FileCategory.videos, '.mkv': FileCategory.videos,
    '.avi': FileCategory.videos, '.mov': FileCategory.videos,
    '.wmv': FileCategory.videos, '.flv': FileCategory.videos,
    '.webm': FileCategory.videos, '.m4v': FileCategory.videos,
    '.ts': FileCategory.videos,

    // Audio
    '.mp3': FileCategory.audio, '.wav': FileCategory.audio,
    '.flac': FileCategory.audio, '.aac': FileCategory.audio,
    '.ogg': FileCategory.audio, '.wma': FileCategory.audio,
    '.m4a': FileCategory.audio, '.opus': FileCategory.audio,

    // Documents
    '.pdf': FileCategory.documents, '.doc': FileCategory.documents,
    '.docx': FileCategory.documents, '.xls': FileCategory.documents,
    '.xlsx': FileCategory.documents, '.ppt': FileCategory.documents,
    '.pptx': FileCategory.documents, '.txt': FileCategory.documents,
    '.rtf': FileCategory.documents, '.odt': FileCategory.documents,
    '.ods': FileCategory.documents, '.csv': FileCategory.documents,
    '.md': FileCategory.documents,

    // Archives
    '.zip': FileCategory.archives, '.tar': FileCategory.archives,
    '.gz': FileCategory.archives, '.bz2': FileCategory.archives,
    '.xz': FileCategory.archives, '.7z': FileCategory.archives,
    '.rar': FileCategory.archives, '.deb': FileCategory.archives,
    '.rpm': FileCategory.archives, '.zst': FileCategory.archives,

    // Code
    '.dart': FileCategory.code, '.py': FileCategory.code,
    '.js': FileCategory.code, '.java': FileCategory.code,
    '.c': FileCategory.code, '.cpp': FileCategory.code,
    '.h': FileCategory.code, '.hpp': FileCategory.code,
    '.rs': FileCategory.code, '.go': FileCategory.code,
    '.rb': FileCategory.code, '.php': FileCategory.code,
    '.html': FileCategory.code, '.css': FileCategory.code,
    '.json': FileCategory.code, '.xml': FileCategory.code,
    '.yaml': FileCategory.code, '.yml': FileCategory.code,
    '.sh': FileCategory.code, '.sql': FileCategory.code,
    '.kt': FileCategory.code, '.swift': FileCategory.code,
  };

  /// Returns the [FileCategory] for the given [filename].
  static FileCategory categorize(String filename) {
    final ext = p.extension(filename).toLowerCase();
    return _extensionMap[ext] ?? FileCategory.other;
  }

  /// Returns the [FileCategory] for the given extension (with dot).
  static FileCategory fromExtension(String extension_) {
    return _extensionMap[extension_.toLowerCase()] ?? FileCategory.other;
  }
}
