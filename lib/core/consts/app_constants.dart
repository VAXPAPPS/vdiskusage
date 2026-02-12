import 'package:flutter/material.dart';

/// App-wide constants for the Disk Usage Analyzer
class AppConstants {
  AppConstants._();

  // ── Window ──
  static const String appTitle = 'Disk Usage Analyzer';
  static const Size defaultWindowSize = Size(1200, 800);

  // ── Scanner ──
  static const int maxScanDepth = 256;
  static const Duration scanUpdateInterval = Duration(milliseconds: 100);
  static const List<String> defaultExcludedPaths = [
    '/proc',
    '/sys',
    '/dev',
    '/run',
    '/snap',
    '/boot/efi',
  ];

  // ── File categories colors ──
  static const Map<String, Color> categoryColors = {
    'images': Color(0xFF4FC3F7),
    'videos': Color(0xFFE57373),
    'audio': Color(0xFFBA68C8),
    'documents': Color(0xFF81C784),
    'archives': Color(0xFFFFB74D),
    'code': Color(0xFF64B5F6),
    'system': Color(0xFF90A4AE),
    'other': Color(0xFFAED581),
  };

  // ── Treemap ──
  static const double treemapMinBlockSize = 4.0;
  static const double treemapPadding = 2.0;

  // ── Cache ──
  static const Duration cacheExpiry = Duration(hours: 1);
  static const String cacheDirectoryName = '.venom_cache';

  // ── UI ──
  static const double sidebarWidth = 64.0;
  static const double sidebarExpandedWidth = 200.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeOutCubic;
}
