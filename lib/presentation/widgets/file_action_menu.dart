import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';

/// Context menu for file actions.
class FileActionMenu extends StatelessWidget {
  final FileNode node;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenInFileManager;
  final VoidCallback? onOpenDirectory;

  const FileActionMenu({
    super.key,
    required this.node,
    this.onDelete,
    this.onOpenInFileManager,
    this.onOpenDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (node.isDirectory && onOpenDirectory != null)
            _ActionItem(
              icon: Icons.folder_open_rounded,
              label: 'Open',
              onTap: onOpenDirectory!,
            ),
          _ActionItem(
            icon: Icons.open_in_new_rounded,
            label: 'Open in Files',
            onTap: onOpenInFileManager ?? () {},
          ),
          _ActionItem(
            icon: Icons.content_copy_rounded,
            label: 'Copy Path',
            onTap: () {
              Clipboard.setData(ClipboardData(text: node.path));
              Navigator.of(context).pop();
            },
          ),
          Divider(
            color: Colors.white.withOpacity(0.08),
            height: 8,
          ),
          _ActionItem(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: const Color(0xFFEF5350),
            onTap: onDelete ?? () {},
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: _isHovered ? Colors.white.withOpacity(0.08) : null,
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: color.withOpacity(0.7)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
