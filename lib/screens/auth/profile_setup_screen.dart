import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/custom_button.dart';
import 'package:flutter_community_app/widgets/profile_avatar.dart';
import 'package:flutter_community_app/services/auth_service.dart';
import 'package:flutter_community_app/utils/error_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedBranch;
  String? _selectedYear;
  bool _isLoading = false;
  String? _avatarUrl;
  String? _localAvatarPath;
  String? _errorMessage;

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Artificial Intelligence & Data Science',
    'Electronics',
    'Mechanical',
    'Civil',
    'Chemical',
  ];

  final List<String> _years = [
    'First Year',
    'Second Year',
    'Third Year',
    'Final Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _avatarUrl = user.avatarUrl;
        _selectedBranch = user.department;
        _selectedYear = user.year;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _localAvatarPath = pickedFile.path;
      });
    }
  }

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate() && _selectedBranch != null && _selectedYear != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = ref.read(authServiceProvider);

        // Upload avatar if selected
        String? newAvatarUrl = _avatarUrl;
        if (_localAvatarPath != null) {
          final fileName = _localAvatarPath!.split('/').last;
          newAvatarUrl = await authService.uploadAvatar(_localAvatarPath!, fileName);
        }

        final result = await authService.updateProfile(
          name: _nameController.text.trim(),
          avatarUrl: newAvatarUrl,
          department: _selectedBranch,
          year: _selectedYear,
        );

        if (result.success && mounted) {
          context.go('/home');
        } else {
          setState(() {
            _errorMessage = result.errorMessage ?? 'Profile update failed';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Profile setup failed: ${e.toString()}';
        });
        ErrorHandler.logError('ProfileSetupScreen._completeProfile', e, null);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Show validation errors
      if (_selectedBranch == null) {
        setState(() {
          _errorMessage = 'Please select your branch';
        });
      } else if (_selectedYear == null) {
        setState(() {
          _errorMessage = 'Please select your year';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _getAvatarImage(),
                        child: _getAvatarImage() == null
                            ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
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
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tell us about yourself',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This information will be displayed on your profile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message if any
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Profile form
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Branch dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: Text(branch),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranch = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Year dropdown
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: _years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Complete Profile',
                  isLoading: _isLoading,
                  onPressed: _completeProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_localAvatarPath != null) {
      return FileImage(File(_localAvatarPath!));
    } else if (_avatarUrl != null) {
      return NetworkImage(_avatarUrl!);
    }
    return null;
  }
}
