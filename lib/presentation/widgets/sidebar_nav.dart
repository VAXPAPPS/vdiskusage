import 'package:flutter/material.dart';
import 'package:vdiskusage/core/consts/app_constants.dart';

/// Glassmorphic sidebar navigation.
class SidebarNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SidebarNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends State<SidebarNav> {
  bool _isExpanded = false;

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.radar_rounded, label: 'Scanner'),
    _NavItem(icon: Icons.folder_open_rounded, label: 'Explorer'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = _isExpanded
        ? AppConstants.sidebarExpandedWidth
        : AppConstants.sidebarWidth;

    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        curve: AppConstants.animationCurve,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Logo area
            AnimatedContainer(
              duration: AppConstants.animationDuration,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.storage_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.08),
              height: 24,
              indent: 12,
              endIndent: 12,
            ),
            // Nav items
            ...List.generate(_items.length, (index) {
              return _buildNavItem(index, _items[index]);
            }),
            const Spacer(),
            // Version info
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'v0.1.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withOpacity(0.08),
          splashColor: Colors.white.withOpacity(0.12),
          child: AnimatedContainer(
            duration: AppConstants.animationDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.1))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isExpanded ? 1.0 : 0.0,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
