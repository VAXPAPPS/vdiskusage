/// Categories for classifying files by type.
enum FileCategory {
  images,
  videos,
  audio,
  documents,
  archives,
  code,
  system,
  other;

  String get label {
    switch (this) {
      case FileCategory.images:
        return 'Images';
      case FileCategory.videos:
        return 'Videos';
      case FileCategory.audio:
        return 'Audio';
      case FileCategory.documents:
        return 'Documents';
      case FileCategory.archives:
        return 'Archives';
      case FileCategory.code:
        return 'Code';
      case FileCategory.system:
        return 'System';
      case FileCategory.other:
        return 'Other';
    }
  }
}
