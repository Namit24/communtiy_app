import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/paper.dart';
import 'package:flutter_community_app/theme/app_theme.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  
  const PaperCard({
    super.key,
    required this.paper,
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
                color: _getColorForExamType(paper.examType),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  paper.year,
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
                    paper.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${paper.subject} • ${paper.examType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'By ${paper.uploadedBy}',
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
                        paper.uploadDate,
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
                  '${paper.downloadCount} downloads',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {
                    // Download paper
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForExamType(String examType) {
    switch (examType) {
      case 'End Semester':
        return Colors.purple;
      case 'Mid Semester':
        return Colors.blue;
      case 'Quiz':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
