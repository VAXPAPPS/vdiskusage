import 'package:flutter/material.dart';

/// Breadcrumb navigation bar for treemap drill-down.
class BreadcrumbBar extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onBack;

  const BreadcrumbBar({
    super.key,
    required this.items,
    this.onItemTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (items.length > 1)
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          if (items.length > 1) const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildBreadcrumbs(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbs() {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;

      if (i > 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        );
      }

      widgets.add(
        InkWell(
          onTap: isLast ? null : () => onItemTap?.call(i),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              items[i],
              style: TextStyle(
                fontSize: 12,
                color: isLast
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
