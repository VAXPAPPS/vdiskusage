import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/settings/settings_event.dart';
import 'package:vdiskusage/application/settings/settings_state.dart';
import 'package:vdiskusage/core/consts/app_constants.dart';
import 'package:vdiskusage/infrastructure/services/cache_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final CacheService _cacheService;
  List<String> _excludedDirs = List.from(AppConstants.defaultExcludedPaths);
  int _maxDepth = AppConstants.maxScanDepth;

  SettingsBloc({CacheService? cacheService})
      : _cacheService = cacheService ?? CacheService(),
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateExcludedDirs>(_onUpdateExcludedDirs);
    on<UpdateMaxDepth>(_onUpdateMaxDepth);
    on<ClearCache>(_onClearCache);
  }

  List<String> get excludedDirs => _excludedDirs;
  int get maxDepth => _maxDepth;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final cacheSize = await _cacheService.getCacheSize();
    emit(SettingsLoaded(
      excludedDirs: _excludedDirs,
      maxDepth: _maxDepth,
      cacheSizeBytes: cacheSize,
    ));
  }

  void _onUpdateExcludedDirs(
    UpdateExcludedDirs event,
    Emitter<SettingsState> emit,
  ) {
    _excludedDirs = event.excludedDirs;
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(excludedDirs: _excludedDirs));
    }
  }

  void _onUpdateMaxDepth(
    UpdateMaxDepth event,
    Emitter<SettingsState> emit,
  ) {
    _maxDepth = event.maxDepth;
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(maxDepth: _maxDepth));
    }
  }

  Future<void> _onClearCache(
    ClearCache event,
    Emitter<SettingsState> emit,
  ) async {
    await _cacheService.clearAll();
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(cacheSizeBytes: 0));
    }
  }
}
