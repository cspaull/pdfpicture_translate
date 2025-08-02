import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/translation_job.dart';
import '../utils/file_utils.dart';

class TranslationJobCard extends StatelessWidget {
  final TranslationJob job;
  final VoidCallback onDelete;
  
  const TranslationJobCard({
    super.key,
    required this.job,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with file name and menu
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.fileName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getLanguageName(job.sourceLang)} → ${_getLanguageName(job.targetLang)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (job.status == TranslationStatus.completed && job.outputPath != null)
                      PopupMenuItem(
                        onTap: () => FileUtils.openFile(job.outputPath!),
                        child: const Row(
                          children: [
                            Icon(Icons.open_in_new),
                            SizedBox(width: 8),
                            Text('Mở file'),
                          ],
                        ),
                      ),
                    if (job.status == TranslationStatus.completed && job.outputPath != null)
                      PopupMenuItem(
                        onTap: () => FileUtils.shareFile(job.outputPath!),
                        child: const Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Chia sẻ'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status and progress
            Row(
              children: [
                _buildStatusIcon(context),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.statusText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(),
                        ),
                      ),
                      if (job.status == TranslationStatus.processing) ...[
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: job.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(job.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else if (job.status == TranslationStatus.failed && job.error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          job.error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Footer with timestamp and actions
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(job.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                if (job.processingTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(job.processingTime!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                const Spacer(),
                if (job.status == TranslationStatus.completed && job.outputPath != null)
                  ElevatedButton.icon(
                    onPressed: () => FileUtils.openFile(job.outputPath!),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Mở'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIcon(BuildContext context) {
    switch (job.status) {
      case TranslationStatus.processing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      case TranslationStatus.completed:
        return Icon(
          Icons.check_circle,
          size: 20,
          color: Colors.green[600],
        );
      case TranslationStatus.failed:
        return Icon(
          Icons.error,
          size: 20,
          color: Colors.red[600],
        );
    }
  }
  
  Color _getStatusColor() {
    switch (job.status) {
      case TranslationStatus.processing:
        return Colors.blue[600]!;
      case TranslationStatus.completed:
        return Colors.green[600]!;
      case TranslationStatus.failed:
        return Colors.red[600]!;
    }
  }
  
  String _getLanguageName(String langCode) {
    const languages = {
      'id': 'ID',
      'vi': 'VI',
      'en': 'EN',
      'zh': 'ZH',
      'ja': 'JA',
      'ko': 'KO',
      'th': 'TH',
    };
    return languages[langCode] ?? langCode.toUpperCase();
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }
}