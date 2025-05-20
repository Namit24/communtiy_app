import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/services/data_service.dart';
import 'package:flutter_community_app/services/auth_service.dart';

class AdminSkillsScreen extends ConsumerStatefulWidget {
  const AdminSkillsScreen({super.key});

  @override
  ConsumerState<AdminSkillsScreen> createState() => _AdminSkillsScreenState();
}

class _AdminSkillsScreenState extends ConsumerState<AdminSkillsScreen> {
  List<Skill> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataServiceProvider);
      final skills = await dataService.fetchSkills();

      setState(() {
        _skills = skills;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading skills: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
        ),
        body: const Center(
          child: Text('You do not have admin privileges'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Skills'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSkills,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _skills.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final skill = _skills[index];
            return ListTile(
              title: Text(skill.title),
              subtitle: Text(skill.category),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  // Confirm delete
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Skill'),
                      content: Text('Are you sure you want to delete "${skill.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      final dataService = ref.read(dataServiceProvider);
                      await dataService.deleteSkill(skill.id);
                      _loadSkills();
                    } catch (e) {
                      print('Error deleting skill: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting skill: $e')),
                        );
                      }
                    }
                  }
                },
              ),
              onTap: () {
                // Edit skill
                _showEditSkillDialog(context, skill);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new skill
          _showAddSkillDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final levelController = TextEditingController();
    final timeController = TextEditingController();
    String? selectedCategory;
    bool isSubmitting = false;

    final categories = [
      'Programming',
      'Web Development',
      'Mobile Development',
      'AI & ML',
      'Data Science',
      'Cloud Computing',
      'Cybersecurity',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Skill'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: levelController,
                      decoration: const InputDecoration(
                        labelText: 'Level (e.g., Beginner, Intermediate)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Time (e.g., 3 months)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ||
                      titleController.text.trim().isEmpty ||
                      selectedCategory == null ||
                      descriptionController.text.trim().isEmpty ||
                      levelController.text.trim().isEmpty ||
                      timeController.text.trim().isEmpty
                      ? null
                      : () async {
                    setState(() {
                      isSubmitting = true;
                    });

                    try {
                      final dataService = ref.read(dataServiceProvider);
                      await dataService.createSkill(
                        title: titleController.text.trim(),
                        category: selectedCategory!,
                        description: descriptionController.text.trim(),
                        level: levelController.text.trim(),
                        estimatedTime: timeController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        _loadSkills();
                      }
                    } catch (e) {
                      print('Error creating skill: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error creating skill: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isSubmitting = false;
                        });
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSkillDialog(BuildContext context, Skill skill) {
    final titleController = TextEditingController(text: skill.title);
    final descriptionController = TextEditingController(text: skill.description);
    final levelController = TextEditingController(text: skill.level);
    final timeController = TextEditingController(text: skill.estimatedTime);
    String? selectedCategory = skill.category;
    bool isSubmitting = false;

    final categories = [
      'Programming',
      'Web Development',
      'Mobile Development',
      'AI & ML',
      'Data Science',
      'Cloud Computing',
      'Cybersecurity',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Skill'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: levelController,
                      decoration: const InputDecoration(
                        labelText: 'Level (e.g., Beginner, Intermediate)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Time (e.g., 3 months)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ||
                      titleController.text.trim().isEmpty ||
                      selectedCategory == null ||
                      descriptionController.text.trim().isEmpty ||
                      levelController.text.trim().isEmpty ||
                      timeController.text.trim().isEmpty
                      ? null
                      : () async {
                    setState(() {
                      isSubmitting = true;
                    });

                    try {
                      final dataService = ref.read(dataServiceProvider);
                      // In a real app, you would have an updateSkill method
                      await dataService.updateSkill(
                        id: skill.id,
                        title: titleController.text.trim(),
                        category: selectedCategory!,
                        description: descriptionController.text.trim(),
                        level: levelController.text.trim(),
                        estimatedTime: timeController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        _loadSkills();
                      }
                    } catch (e) {
                      print('Error updating skill: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating skill: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isSubmitting = false;
                        });
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
