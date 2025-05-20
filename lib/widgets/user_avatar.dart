import 'package:flutter/material.dart';
import 'package:flutter_community_app/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String? avatarUrl;
  final bool showBadge;
  
  const UserAvatar({
    super.key,
    required this.radius,
    required this.avatarUrl,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: radius,
                  color: Colors.grey.shade400,
                )
              : null,
        ),
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
