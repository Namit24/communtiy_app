import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? avatarUrl;
  final Function(String) onChanged;
  
  const ProfileAvatar({
    super.key,
    required this.radius,
    required this.avatarUrl,
    required this.onChanged,
  });

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (pickedFile != null) {
        // In a real app, you would upload the image to a server and get a URL
        // For now, we'll just pass the local path
        print("Image picked: ${pickedFile.path}");
        onChanged(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: avatarUrl != null ? 
            (kIsWeb ? NetworkImage(avatarUrl!) : AssetImage(avatarUrl!) as ImageProvider) 
            : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: radius,
                  color: Colors.grey.shade400,
                )
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
