class Note {
  final String id;
  final String title;
  final String subject;
  final String uploadedBy;
  final String uploadDate;
  final String fileSize;
  final String fileType;
  final int downloadCount;
  
  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.uploadedBy,
    required this.uploadDate,
    required this.fileSize,
    required this.fileType,
    required this.downloadCount,
  });
}
