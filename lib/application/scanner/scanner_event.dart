import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning a directory.
class StartScan extends ScannerEvent {
  final String path;

  const StartScan({required this.path});

  @override
  List<Object?> get props => [path];
}

/// Cancel the ongoing scan.
class CancelScan extends ScannerEvent {
  const CancelScan();
}

/// Navigate into a child node (drill-down in treemap).
class NavigateToNode extends ScannerEvent {
  final int nodeIndex;

  const NavigateToNode({required this.nodeIndex});

  @override
  List<Object?> get props => [nodeIndex];
}

/// Go back to parent node.
class GoBack extends ScannerEvent {
  const GoBack();
}

/// Go to a specific breadcrumb index.
class GoToBreadcrumb extends ScannerEvent {
  final int index;

  const GoToBreadcrumb({required this.index});

  @override
  List<Object?> get props => [index];
}
