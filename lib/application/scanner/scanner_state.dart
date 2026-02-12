import 'package:equatable/equatable.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerScanning extends ScannerState {
  final ScanProgress progress;

  const ScannerScanning({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class ScannerCompleted extends ScannerState {
  final FileNode rootNode;
  final FileNode currentNode;
  final List<FileNode> breadcrumbs;

  const ScannerCompleted({
    required this.rootNode,
    required this.currentNode,
    required this.breadcrumbs,
  });

  @override
  List<Object?> get props => [rootNode, currentNode, breadcrumbs];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
