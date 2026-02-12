import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vdiskusage/application/settings/settings_bloc.dart';
import 'package:vdiskusage/application/settings/settings_event.dart';
import 'package:vdiskusage/application/settings/settings_state.dart';
import 'package:vdiskusage/core/utils/file_size_formatter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                children: [
                  Icon(Icons.settings_rounded, size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Scanner configuration',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: state is SettingsLoaded
                    ? _buildSettings(context, state)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettings(BuildContext context, SettingsLoaded state) {
    return ListView(
      children: [
        // Scan Depth
        _SettingsSection(
          title: 'Scanner',
          children: [
            _SettingsTile(
              icon: Icons.account_tree_rounded,
              title: 'Max Scan Depth',
              subtitle: 'Maximum directory depth to scan',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: state.maxDepth,
                    dropdownColor: const Color(0xFF1E1E2E),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    items: [16, 32, 64, 128, 256]
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text('$d'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<SettingsBloc>()
                            .add(UpdateMaxDepth(maxDepth: v));
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Excluded directories
        _SettingsSection(
          title: 'Excluded Directories',
          children: [
            ...state.excludedDirs.map((dir) {
              return _SettingsTile(
                icon: Icons.folder_off_rounded,
                title: dir,
                trailing: IconButton(
                  onPressed: () {
                    final updated = List<String>.from(state.excludedDirs)
                      ..remove(dir);
                    context
                        .read<SettingsBloc>()
                        .add(UpdateExcludedDirs(excludedDirs: updated));
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              );
            }),
            // Add button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => _addExcludedDir(context, state),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Directory',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cache
        _SettingsSection(
          title: 'Cache',
          children: [
            _SettingsTile(
              icon: Icons.cached_rounded,
              title: 'Cache Size',
              subtitle: FileSizeFormatter.format(state.cacheSizeBytes),
              trailing: TextButton(
                onPressed: () {
                  context.read<SettingsBloc>().add(const ClearCache());
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addExcludedDir(BuildContext context, SettingsLoaded state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add Excluded Directory'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '/path/to/exclude',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                final updated = [...state.excludedDirs, path];
                context
                    .read<SettingsBloc>()
                    .add(UpdateExcludedDirs(excludedDirs: updated));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
