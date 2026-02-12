import 'package:flutter/material.dart';
import 'package:vdiskusage/core/icons/file_type_icons.dart';
import 'package:vdiskusage/core/utils/file_size_formatter.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';
import 'package:vdiskusage/presentation/widgets/size_bar.dart';

/// A single row in the file explorer list.
class FileTreeItem extends StatefulWidget {
  final FileNode node;
  final int parentSize;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final void Function(FileNode)? onContextMenu;

  const FileTreeItem({
    super.key,
    required this.node,
    required this.parentSize,
    this.onTap,
    this.onDoubleTap,
    this.onContextMenu,
  });

  @override
  State<FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<FileTreeItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isDir = node.isDirectory;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTapUp: (details) {
          widget.onContextMenu?.call(node);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                isDir
                    ? FileTypeIcons.folderIcon
                    : FileTypeIcons.icon(node.category),
                color: isDir
                    ? FileTypeIcons.folderColor
                    : FileTypeIcons.color(node.category),
                size: 18,
              ),
              const SizedBox(width: 10),

              // Name
              Expanded(
                flex: 3,
                child: Text(
                  node.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isDir ? FontWeight.w500 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Size bar
              Expanded(
                flex: 2,
                child: SizeBar(
                  value: node.totalSize,
                  maxValue: widget.parentSize,
                  color: isDir
                      ? FileTypeIcons.folderColor
                      : FileTypeIcons.color(node.category),
                ),
              ),
              const SizedBox(width: 12),

              // Size text
              SizedBox(
                width: 72,
                child: Text(
                  FileSizeFormatter.format(node.totalSize),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              // Items count for directories
              if (isDir) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${node.children.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],

              if (!isDir) const SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }
}
