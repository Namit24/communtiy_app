import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/note.dart';
import 'package:flutter_community_app/theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  
  const NoteCard({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getColorForFileType(note.fileType),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  note.fileType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.subject,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'By ${note.uploadedBy}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        note.uploadDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  note.fileSize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {
                    // Download note
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForFileType(String fileType) {
    switch (fileType) {
      case 'PDF':
        return Colors.red;
      case 'DOC':
        return Colors.blue;
      case 'PPT':
        return Colors.orange;
      case 'XLS':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
