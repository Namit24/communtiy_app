class ForumPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String department;
  final String content;
  final int likes;
  final int comments;
  final String timeAgo;
  
  ForumPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.department,
    required this.content,
    required this.likes,
    required this.comments,
    required this.timeAgo,
  });
}
