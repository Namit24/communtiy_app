import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/custom_button.dart';
import 'package:flutter_community_app/widgets/profile_avatar.dart';
import 'package:flutter_community_app/services/auth_service.dart';

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate() && _selectedBranch != null && _selectedYear != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final authService = ref.read(authServiceProvider);
        final user = await authService.updateProfile(
          name: _nameController.text.trim(),
          avatarUrl: _avatarUrl,
          department: _selectedBranch,
          year: _selectedYear,
        );
        
        if (user != null && mounted) {
          context.go('/home');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Profile setup failed: ${e.toString()}';
        });
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

  void _onAvatarChanged(String url) {
    setState(() {
      _avatarUrl = url;
    });
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
                ProfileAvatar(
                  radius: 60,
                  avatarUrl: _avatarUrl,
                  onChanged: _onAvatarChanged,
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
}
