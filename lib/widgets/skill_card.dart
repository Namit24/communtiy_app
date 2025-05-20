import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/theme/app_theme.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;
  
  const SkillCard({
    super.key,
    required this.skill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: _getColorForCategory(skill.category).withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  _getIconForCategory(skill.category),
                  size: 48,
                  color: _getColorForCategory(skill.category),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    skill.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        skill.estimatedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${skill.popularity}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'AI & ML':
        return Colors.purple;
      case 'Web Development':
        return Colors.blue;
      case 'Mobile Development':
        return Colors.orange;
      case 'Data Science':
        return Colors.green;
      case 'Cloud Computing':
        return Colors.cyan;
      case 'Cybersecurity':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'AI & ML':
        return Icons.psychology;
      case 'Web Development':
        return Icons.web;
      case 'Mobile Development':
        return Icons.phone_android;
      case 'Data Science':
        return Icons.analytics;
      case 'Cloud Computing':
        return Icons.cloud;
      case 'Cybersecurity':
        return Icons.security;
      default:
        return Icons.code;
    }
  }
}
