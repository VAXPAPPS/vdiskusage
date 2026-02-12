import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/dashboard/dashboard_bloc.dart';
import 'package:vdiskusage/application/dashboard/dashboard_event.dart';
import 'package:vdiskusage/application/scanner/scanner_bloc.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_bloc.dart';
import 'package:vdiskusage/application/settings/settings_bloc.dart';
import 'package:vdiskusage/application/settings/settings_event.dart';
import 'package:vdiskusage/data/repositories/disk_repository_impl.dart';
import 'package:vdiskusage/data/repositories/scanner_repository_impl.dart';
import 'package:vdiskusage/domain/repositories/disk_repository.dart';
import 'package:vdiskusage/domain/repositories/scanner_repository.dart';
import 'package:vdiskusage/presentation/widgets/sidebar_nav.dart';
import 'package:vdiskusage/presentation/screens/dashboard_screen.dart';
import 'package:vdiskusage/presentation/screens/scanner_screen.dart';
import 'package:vdiskusage/presentation/screens/file_explorer_screen.dart';
import 'package:vdiskusage/presentation/screens/settings_screen.dart';
/// Provides all BLoCs and renders the main app body (sidebar + screens).
/// Designed to be used as the `body` of VenomScaffold.
class DiskAnalyzerBody extends StatelessWidget {
  const DiskAnalyzerBody({super.key});

  @override
  Widget build(BuildContext context) {
    final DiskRepository diskRepo = DiskRepositoryImpl();
    final ScannerRepository scannerRepo = ScannerRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) =>
              DashboardBloc(diskRepository: diskRepo)..add(const LoadDisks()),
        ),
        BlocProvider<ScannerBloc>(
          create: (_) => ScannerBloc(scannerRepository: scannerRepo),
        ),
        BlocProvider<FileExplorerBloc>(
          create: (_) =>
              FileExplorerBloc(scannerRepository: scannerRepo),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc()..add(const LoadSettings()),
        ),
      ],
      child: const _MainContent(),
    );
  }
}

class _MainContent extends StatefulWidget {
  const _MainContent();

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  int _selectedIndex = 0;

  static const _screens = [
    DashboardScreen(),
    ScannerScreen(),
    FileExplorerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SidebarNav(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _screens[_selectedIndex],
          ),
        ),
      ],
    );
  }
}
