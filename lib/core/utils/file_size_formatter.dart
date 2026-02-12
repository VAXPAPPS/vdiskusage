/// Utility for formatting file sizes into human-readable strings.
class FileSizeFormatter {
  FileSizeFormatter._();

  static const List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

  /// Formats [bytes] into a human-readable string like "1.23 GB".
  static String format(int bytes) {
    if (bytes <= 0) return '0 B';

    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < _units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    // No decimals for bytes, 1 decimal for KB, 2 for the rest
    if (unitIndex == 0) return '${size.toInt()} B';
    if (unitIndex == 1) return '${size.toStringAsFixed(1)} KB';
    return '${size.toStringAsFixed(2)} ${_units[unitIndex]}';
  }

  /// Returns a short format like "1.2G" for compact display.
  static String formatCompact(int bytes) {
    if (bytes <= 0) return '0';
    const shortUnits = ['B', 'K', 'M', 'G', 'T', 'P'];

    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < shortUnits.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) return '${size.toInt()}${shortUnits[unitIndex]}';
    return '${size.toStringAsFixed(1)}${shortUnits[unitIndex]}';
  }

  /// Returns the percentage of [used] relative to [total].
  static double percentage(int used, int total) {
    if (total <= 0) return 0.0;
    return (used / total * 100).clamp(0.0, 100.0);
  }
}
