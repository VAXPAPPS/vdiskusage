import 'package:flutter/material.dart';
import 'package:vdiskusage/application/file_explorer/file_explorer_event.dart';
import 'package:vdiskusage/domain/entities/file_category.dart';

/// Search and filter bar for file explorer.
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final SortCriteria sortCriteria;
  final FileCategory? filterCategory;
  final ValueChanged<String> onSearch;
  final ValueChanged<SortCriteria> onSort;
  final ValueChanged<FileCategory?> onFilterCategory;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.sortCriteria,
    required this.filterCategory,
    required this.onSearch,
    required this.onSort,
    required this.onFilterCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search files...',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onSearch,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Sort dropdown
        _buildDropdown<SortCriteria>(
          value: sortCriteria,
          items: SortCriteria.values,
          icon: Icons.sort_rounded,
          labelFn: _sortLabel,
          onChanged: onSort,
        ),
        const SizedBox(width: 8),

        // Category filter
        _buildDropdown<FileCategory?>(
          value: filterCategory,
          items: [null, ...FileCategory.values],
          icon: Icons.filter_list_rounded,
          labelFn: (c) => c?.label ?? 'All',
          onChanged: onFilterCategory,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required IconData icon,
    required String Function(T) labelFn,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(0.5),
          ),
          dropdownColor: const Color(0xFF1E1E2E),
          style: const TextStyle(fontSize: 12, color: Colors.white),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelFn(item),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v is T) onChanged(v);
          },
        ),
      ),
    );
  }

  String _sortLabel(SortCriteria criteria) {
    switch (criteria) {
      case SortCriteria.sizeDesc:
        return 'Size ↓';
      case SortCriteria.sizeAsc:
        return 'Size ↑';
      case SortCriteria.nameAsc:
        return 'Name A-Z';
      case SortCriteria.nameDesc:
        return 'Name Z-A';
      case SortCriteria.dateDesc:
        return 'Date ↓';
      case SortCriteria.dateAsc:
        return 'Date ↑';
    }
  }
}
