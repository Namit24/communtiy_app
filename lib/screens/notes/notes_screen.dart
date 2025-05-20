import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/note.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/note_card.dart';
import 'package:flutter_community_app/services/data_service.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Note> _allNotes = [];
  List<Note> _myNotes = [];
  List<Note> _savedNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataServiceProvider);
      final notes = await dataService.fetchNotes();

      setState(() {
        _allNotes = notes;
        // In a real app, you would filter by user ID
        _myNotes = notes.where((note) => note.isUploadedByMe).toList();
        _savedNotes = notes.where((note) => note.isSaved).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _filteredAllNotes {
    if (_searchQuery.isEmpty) {
      return _allNotes;
    }
    return _allNotes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.uploadedBy.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Note> get _filteredMyNotes {
    if (_searchQuery.isEmpty) {
      return _myNotes;
    }
    return _myNotes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.subject.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Note> get _filteredSavedNotes {
    if (_searchQuery.isEmpty) {
      return _savedNotes;
    }
    return _savedNotes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.uploadedBy.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.subtitleColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All Notes'),
            Tab(text: 'My Uploads'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                // All Notes Tab
                _filteredAllNotes.isEmpty
                    ? const Center(
                  child: Text('No notes found'),
                )
                    : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAllNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return NoteCard(note: _filteredAllNotes[index]);
                    },
                  ),
                ),

                // My Uploads Tab
                _filteredMyNotes.isEmpty
                    ? const Center(
                  child: Text('You haven\'t uploaded any notes yet'),
                )
                    : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMyNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return NoteCard(note: _filteredMyNotes[index]);
                    },
                  ),
                ),

                // Saved Tab
                _filteredSavedNotes.isEmpty
                    ? const Center(
                  child: Text('You haven\'t saved any notes yet'),
                )
                    : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSavedNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return NoteCard(note: _filteredSavedNotes[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Upload new note
          _showUploadDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.upload_file),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    bool isSubmitting = false;
    String? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Upload Notes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.subject),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                      // Pick file
                      setState(() {
                        // In a real app, you would use file_picker
                        selectedFile = 'sample_file.pdf';
                      });
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(selectedFile ?? 'Select File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (isSubmitting || selectedFile == null ||
                        titleController.text.trim().isEmpty ||
                        subjectController.text.trim().isEmpty)
                        ? null
                        : () async {
                      setState(() {
                        isSubmitting = true;
                      });

                      try {
                        final dataService = ref.read(dataServiceProvider);
                        await dataService.createNote(
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          fileUrl: 'https://example.com/files/$selectedFile',
                          fileSize: '1.2 MB',
                          fileType: 'PDF',
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          _loadNotes();
                        }
                      } catch (e) {
                        print('Error uploading note: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error uploading note: $e')),
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
                        : const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
