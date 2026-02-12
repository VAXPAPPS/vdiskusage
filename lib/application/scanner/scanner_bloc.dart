import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/scanner/scanner_event.dart';
import 'package:vdiskusage/application/scanner/scanner_state.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/domain/entities/scan_progress.dart';
import 'package:vdiskusage/domain/repositories/scanner_repository.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScannerRepository _scannerRepository;
  StreamSubscription<ScanProgress>? _scanSubscription;

  ScannerBloc({required ScannerRepository scannerRepository})
      : _scannerRepository = scannerRepository,
        super(const ScannerInitial()) {
    on<StartScan>(_onStartScan);
    on<CancelScan>(_onCancelScan);
    on<NavigateToNode>(_onNavigateToNode);
    on<GoBack>(_onGoBack);
    on<GoToBreadcrumb>(_onGoToBreadcrumb);
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<ScannerState> emit,
  ) async {
    await _scanSubscription?.cancel();

    emit(const ScannerScanning(progress: ScanProgress()));

    await emit.forEach<ScanProgress>(
      _scannerRepository.scanDirectory(event.path),
      onData: (progress) {
        if (progress.isComplete) {
          return _handleScanComplete();
        }
        return ScannerScanning(progress: progress);
      },
      onError: (error, _) => ScannerError(message: error.toString()),
    );
  }

  ScannerState _handleScanComplete() {
    // Get the result tree asynchronously and emit completed state
    _scannerRepository.getScanResult().then((result) {
      if (result != null) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(ScannerCompleted(
          rootNode: result,
          currentNode: result,
          breadcrumbs: [result],
        ));
      }
    });

    // Return scanning state until async fetch completes
    return const ScannerScanning(
      progress: ScanProgress(isComplete: true),
    );
  }

  void _onCancelScan(CancelScan event, Emitter<ScannerState> emit) {
    _scannerRepository.cancelScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(const ScannerInitial());
  }

  void _onNavigateToNode(NavigateToNode event, Emitter<ScannerState> emit) {
    final currentState = state;
    if (currentState is! ScannerCompleted) return;

    final children = currentState.currentNode.childrenSortedBySize;
    if (event.nodeIndex < 0 || event.nodeIndex >= children.length) return;

    final targetNode = children[event.nodeIndex];
    if (!targetNode.isDirectory || targetNode.children.isEmpty) return;

    emit(ScannerCompleted(
      rootNode: currentState.rootNode,
      currentNode: targetNode,
      breadcrumbs: [...currentState.breadcrumbs, targetNode],
    ));
  }

  void _onGoBack(GoBack event, Emitter<ScannerState> emit) {
    final currentState = state;
    if (currentState is! ScannerCompleted) return;
    if (currentState.breadcrumbs.length <= 1) return;

    final newBreadcrumbs = List<FileNode>.from(currentState.breadcrumbs)
      ..removeLast();

    emit(ScannerCompleted(
      rootNode: currentState.rootNode,
      currentNode: newBreadcrumbs.last,
      breadcrumbs: newBreadcrumbs,
    ));
  }

  void _onGoToBreadcrumb(GoToBreadcrumb event, Emitter<ScannerState> emit) {
    final currentState = state;
    if (currentState is! ScannerCompleted) return;
    if (event.index < 0 || event.index >= currentState.breadcrumbs.length) {
      return;
    }

    final newBreadcrumbs =
        currentState.breadcrumbs.sublist(0, event.index + 1);

    emit(ScannerCompleted(
      rootNode: currentState.rootNode,
      currentNode: newBreadcrumbs.last,
      breadcrumbs: newBreadcrumbs,
    ));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
