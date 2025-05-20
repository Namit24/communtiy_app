import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/paper.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/paper_card.dart';

class PapersScreen extends StatefulWidget {
  const PapersScreen({super.key});

  @override
  State<PapersScreen> createState() => _PapersScreenState();
}

class _PapersScreenState extends State<PapersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedYear = 'All';
  String _selectedSubject = 'All';

  final List<String> _years = ['All', '2023', '2022', '2021', '2020', '2019'];
  final List<String> _subjects = [
    'All',
    'Machine Learning',
    'Data Structures',
    'Database Systems',
    'Computer Networks',
    'Operating Systems',
  ];

  final List<Paper> _papers = [
    Paper(
      id: '1',
      title: 'Machine Learning End Semester',
      subject: 'Machine Learning',
      year: '2023',
      examType: 'End Semester',
      uploadedBy: 'Prof. Sharma',
      uploadDate: '15 June 2023',
      fileSize: '1.2 MB',
      fileType: 'PDF',
      downloadCount: 85,
    ),
    Paper(
      id: '2',
      title: 'Data Structures Mid Semester',
      subject: 'Data Structures',
      year: '2023',
      examType: 'Mid Semester',
      uploadedBy: 'Prof. Patel',
      uploadDate: '10 March 2023',
      fileSize: '0.8 MB',
      fileType: 'PDF',
      downloadCount: 120,
    ),
    Paper(
      id: '3',
      title: 'Database Systems End Semester',
      subject: 'Database Systems',
      year: '2022',
      examType: 'End Semester',
      uploadedBy: 'Prof. Gupta',
      uploadDate: '20 December 2022',
      fileSize: '1.5 MB',
      fileType: 'PDF',
      downloadCount: 95,
    ),
    Paper(
      id: '4',
      title: 'Computer Networks Mid Semester',
      subject: 'Computer Networks',
      year: '2022',
      examType: 'Mid Semester',
      uploadedBy: 'Prof. Kumar',
      uploadDate: '5 October 2022',
      fileSize: '1.0 MB',
      fileType: 'PDF',
      downloadCount: 75,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Paper> get _filteredPapers {
    return _papers.where((paper) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          paper.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          paper.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by year
      final matchesYear = _selectedYear == 'All' || paper.year == _selectedYear;
      
      // Filter by subject
      final matchesSubject = _selectedSubject == 'All' || paper.subject == _selectedSubject;
      
      return matchesSearch && matchesYear && matchesSubject;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Papers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search papers...',
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPapers.isEmpty
                ? const Center(
                    child: Text('No papers found'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPapers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return PaperCard(paper: _filteredPapers[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Upload new paper
          _showUploadDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.upload_file),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
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
                      'Upload Question Paper',
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: '2023',
                      decoration: const InputDecoration(
                        labelText: 'Year',
                      ),
                      items: _years.where((year) => year != 'All').map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Update year
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: 'End Semester',
                      decoration: const InputDecoration(
                        labelText: 'Exam Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'End Semester',
                          child: Text('End Semester'),
                        ),
                        DropdownMenuItem(
                          value: 'Mid Semester',
                          child: Text('Mid Semester'),
                        ),
                        DropdownMenuItem(
                          value: 'Quiz',
                          child: Text('Quiz'),
                        ),
                      ],
                      onChanged: (value) {
                        // Update exam type
                      },
                    ),
                  ),
                ],
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
