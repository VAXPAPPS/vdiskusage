#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <errno.h>
#include <unistd.h>

/*
 * Venom Disk Usage Analyzer — Native Scanner (FFI)
 *
 * High-performance file system scanner using direct syscalls.
 * Called from Dart via FFI for maximum scanning speed.
 */

// ── Structures ──

typedef struct {
    char path[4096];
    long long size;
    long long mtime;
    int is_dir;
    int depth;
} FileEntry;

typedef struct {
    FileEntry *entries;
    int count;
    int capacity;
    long long total_size;
    int file_count;
    int dir_count;
    volatile int *cancel_flag;
} ScanResult;

typedef struct {
    long long total_bytes;
    long long free_bytes;
    long long available_bytes;
    long long used_bytes;
    char filesystem[256];
    char mount_point[4096];
    char device[4096];
} DiskStats;

// ── Internal helpers ──

static void ensure_capacity(ScanResult *result) {
    if (result->count >= result->capacity) {
        result->capacity = result->capacity * 2;
        result->entries = (FileEntry *)realloc(
            result->entries, sizeof(FileEntry) * result->capacity
        );
    }
}

static void scan_recursive(
    const char *dir_path,
    ScanResult *result,
    int current_depth,
    int max_depth
) {
    // Check cancellation
    if (result->cancel_flag && *(result->cancel_flag)) return;
    if (current_depth > max_depth) return;

    DIR *dir = opendir(dir_path);
    if (!dir) return;

    struct dirent *entry;
    struct stat st;
    char full_path[4096];

    while ((entry = readdir(dir)) != NULL) {
        // Check cancellation periodically
        if (result->cancel_flag && *(result->cancel_flag)) break;

        // Skip . and ..
        if (entry->d_name[0] == '.' &&
            (entry->d_name[1] == '\0' ||
             (entry->d_name[1] == '.' && entry->d_name[2] == '\0'))) {
            continue;
        }

        // Build full path
        int len = snprintf(full_path, sizeof(full_path), "%s/%s",
                           dir_path, entry->d_name);
        if (len >= (int)sizeof(full_path)) continue;  // Path too long

        // Use lstat to avoid following symlinks
        if (lstat(full_path, &st) != 0) continue;

        // Skip special files (devices, sockets, etc.)
        if (!S_ISREG(st.st_mode) && !S_ISDIR(st.st_mode)) continue;

        ensure_capacity(result);

        FileEntry *fe = &result->entries[result->count];
        strncpy(fe->path, full_path, sizeof(fe->path) - 1);
        fe->path[sizeof(fe->path) - 1] = '\0';
        fe->size = (long long)st.st_size;
        fe->mtime = (long long)st.st_mtime;
        fe->is_dir = S_ISDIR(st.st_mode) ? 1 : 0;
        fe->depth = current_depth;
        result->count++;

        if (S_ISDIR(st.st_mode)) {
            result->dir_count++;
            // Recurse into subdirectory
            scan_recursive(full_path, result, current_depth + 1, max_depth);
        } else {
            result->file_count++;
            result->total_size += (long long)st.st_size;
        }
    }

    closedir(dir);
}

// ── Public API (called from Dart FFI) ──

/**
 * Allocates a cancel flag. Returns pointer to int.
 * Set *flag = 1 from Dart to cancel an ongoing scan.
 */
int *create_cancel_flag(void) {
    int *flag = (int *)calloc(1, sizeof(int));
    return flag;
}

void free_cancel_flag(int *flag) {
    if (flag) free(flag);
}

/**
 * Scans a directory tree. Returns a ScanResult pointer.
 * Caller must free with free_scan_result().
 */
ScanResult *scan_directory(
    const char *path,
    int max_depth,
    int *cancel_flag
) {
    ScanResult *result = (ScanResult *)calloc(1, sizeof(ScanResult));
    result->capacity = 8192;
    result->entries = (FileEntry *)malloc(sizeof(FileEntry) * result->capacity);
    result->count = 0;
    result->total_size = 0;
    result->file_count = 0;
    result->dir_count = 0;
    result->cancel_flag = cancel_flag;

    scan_recursive(path, result, 0, max_depth);

    return result;
}

/** Returns the number of entries in the result. */
int result_count(ScanResult *result) {
    return result ? result->count : 0;
}

/** Returns total size in bytes. */
long long result_total_size(ScanResult *result) {
    return result ? result->total_size : 0;
}

int result_file_count(ScanResult *result) {
    return result ? result->file_count : 0;
}

int result_dir_count(ScanResult *result) {
    return result ? result->dir_count : 0;
}

/** Access entry at index. Returns NULL if out of bounds. */
FileEntry *result_entry_at(ScanResult *result, int index) {
    if (!result || index < 0 || index >= result->count) return NULL;
    return &result->entries[index];
}

/** Returns the path of an entry. */
const char *entry_path(FileEntry *entry) {
    return entry ? entry->path : "";
}

long long entry_size(FileEntry *entry) {
    return entry ? entry->size : 0;
}

long long entry_mtime(FileEntry *entry) {
    return entry ? entry->mtime : 0;
}

int entry_is_dir(FileEntry *entry) {
    return entry ? entry->is_dir : 0;
}

int entry_depth(FileEntry *entry) {
    return entry ? entry->depth : 0;
}

/** Frees all memory associated with a scan result. */
void free_scan_result(ScanResult *result) {
    if (result) {
        if (result->entries) free(result->entries);
        free(result);
    }
}

/**
 * Gets disk usage stats for a given path (mount point).
 * Returns 0 on success, -1 on failure.
 */
int get_disk_stats(const char *path, DiskStats *stats) {
    if (!path || !stats) return -1;

    struct statvfs vfs;
    if (statvfs(path, &vfs) != 0) return -1;

    stats->total_bytes = (long long)vfs.f_blocks * vfs.f_frsize;
    stats->free_bytes = (long long)vfs.f_bfree * vfs.f_frsize;
    stats->available_bytes = (long long)vfs.f_bavail * vfs.f_frsize;
    stats->used_bytes = stats->total_bytes - stats->free_bytes;

    strncpy(stats->mount_point, path, sizeof(stats->mount_point) - 1);
    stats->mount_point[sizeof(stats->mount_point) - 1] = '\0';

    return 0;
}
