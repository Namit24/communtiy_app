class Paper {
  final String id;
  final String title;
  final String subject;
  final String year;
  final String examType;
  final String uploadedBy;
  final String uploadDate;
  final String fileSize;
  final String fileType;
  final int downloadCount;
  
  Paper({
    required this.id,
    required this.title,
    required this.subject,
    required this.year,
    required this.examType,
    required this.uploadedBy,
    required this.uploadDate,
    required this.fileSize,
    required this.fileType,
    required this.downloadCount,
  });
}
