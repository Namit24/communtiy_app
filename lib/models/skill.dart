class Skill {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? imageUrl;
  final String level;
  final String estimatedTime;
  final int popularity;
  
  Skill({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.level,
    required this.estimatedTime,
    required this.popularity,
  });
}
