import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/note.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Machine Learning Fundamentals',
      subject: 'Artificial Intelligence',
      uploadedBy: 'Prof. Sharma',
      uploadDate: '10 May 2023',
      fileSize: '2.5 MB',
      fileType: 'PDF',
      downloadCount: 120,
    ),
    Note(
      id: '2',
      title: 'Data Structures and Algorithms',
      subject: 'Computer Science',
      uploadedBy: 'Rahul Patel',
      uploadDate: '5 June 2023',
      fileSize: '1.8 MB',
      fileType: 'PDF',
      downloadCount: 85,
    ),
    Note(
      id: '3',
      title: 'Database Management Systems',
      subject: 'Information Technology',
      uploadedBy: 'Ananya Gupta',
      uploadDate: '20 April 2023',
      fileSize: '3.2 MB',
      fileType: 'PDF',
      downloadCount: 150,
    ),
    Note(
      id: '4',
      title: 'Neural Networks and Deep Learning',
      subject: 'Artificial Intelligence',
      uploadedBy: 'Prof. Kumar',
      uploadDate: '15 July 2023',
      fileSize: '4.5 MB',
      fileType: 'PDF',
      downloadCount: 95,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) {
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
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Notes Tab
                _filteredNotes.isEmpty
                    ? const Center(
                        child: Text('No notes found'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredNotes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return NoteCard(note: _filteredNotes[index]);
                        },
                      ),
                
                // My Uploads Tab
                const Center(
                  child: Text('You haven\'t uploaded any notes yet'),
                ),
                
                // Saved Tab
                const Center(
                  child: Text('You haven\'t saved any notes yet'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.subject),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Pick file
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Select File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Upload file
                  Navigator.pop(context);
                },
                child: const Text('Upload'),
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
  }
}
