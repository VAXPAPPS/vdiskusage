import 'package:flutter/material.dart';
import 'package:vdiskusage/core/colors/vaxp_colors.dart';
import 'package:vdiskusage/core/consts/app_constants.dart';
import 'package:vdiskusage/core/venom_layout.dart';
import 'package:vdiskusage/presentation/app.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: AppConstants.defaultWindowSize,
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const DiskAnalyzerApp());
}

class DiskAnalyzerApp extends StatelessWidget {
  const DiskAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      home: const VenomScaffold(
        title: 'Disk Usage Analyzer',
        body: DiskAnalyzerBody(),
      ),
    );
  }
}
