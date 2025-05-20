import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/skill_card.dart';
import 'package:go_router/go_router.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Programming',
    'Web Development',
    'Mobile Development',
    'AI & ML',
    'Data Science',
    'Cloud Computing',
    'Cybersecurity',
  ];

  final List<Skill> _skills = [
    Skill(
      id: '1',
      title: 'Machine Learning',
      category: 'AI & ML',
      description: 'Learn the fundamentals of machine learning algorithms and applications.',
      imageUrl: null,
      level: 'Intermediate',
      estimatedTime: '3 months',
      popularity: 95,
    ),
    Skill(
      id: '2',
      title: 'Web Development',
      category: 'Web Development',
      description: 'Master modern web development with HTML, CSS, JavaScript, and popular frameworks.',
      imageUrl: null,
      level: 'Beginner to Advanced',
      estimatedTime: '6 months',
      popularity: 98,
    ),
    Skill(
      id: '3',
      title: 'Flutter Development',
      category: 'Mobile Development',
      description: 'Build beautiful cross-platform mobile apps with Flutter and Dart.',
      imageUrl: null,
      level: 'Intermediate',
      estimatedTime: '4 months',
      popularity: 90,
    ),
    Skill(
      id: '4',
      title: 'Data Science',
      category: 'Data Science',
      description: 'Learn data analysis, visualization, and statistical modeling techniques.',
      imageUrl: null,
      level: 'Intermediate to Advanced',
      estimatedTime: '5 months',
      popularity: 92,
    ),
    Skill(
      id: '5',
      title: 'Cloud Computing',
      category: 'Cloud Computing',
      description: 'Master cloud platforms like AWS, Azure, and Google Cloud.',
      imageUrl: null,
      level: 'Intermediate',
      estimatedTime: '3 months',
      popularity: 88,
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

  List<Skill> get _filteredSkills {
    return _skills.where((skill) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          skill.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          skill.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by category
      final matchesCategory = _selectedCategory == 'All' || skill.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
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
                    hintText: 'Search skills...',
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
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.subtitleColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredSkills.isEmpty
                ? const Center(
                    child: Text('No skills found'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredSkills.length,
                    itemBuilder: (context, index) {
                      return SkillCard(
                        skill: _filteredSkills[index],
                        onTap: () {
                          context.go('/skills/${_filteredSkills[index].id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
