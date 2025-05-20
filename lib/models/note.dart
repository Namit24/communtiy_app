class Note {
  final String id;
  final String title;
  final String subject;
  final String uploadedBy;
  final String uploadDate;
  final String fileSize;
  final String fileType;
  final int downloadCount;
  final bool isUploadedByMe;
  final bool isSaved;

  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.uploadedBy,
    required this.uploadDate,
    required this.fileSize,
    required this.fileType,
    required this.downloadCount,
    this.isUploadedByMe = false,
    this.isSaved = false,
  });

  // Create a note from JSON data
  factory Note.fromJson(Map<String, dynamic> json, {required String currentUserId}) {
    final uploaderId = json['userId'] ?? '';

    return Note(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      uploadedBy: json['uploadedBy']['name'] ?? 'Unknown',
      uploadDate: json['createdAt'] ?? 'Unknown date',
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      downloadCount: json['downloadCount'] ?? 0,
      isUploadedByMe: uploaderId == currentUserId,
      // In a real app, you would check if this note is in the user's saved notes
      isSaved: false,
    );
  }
}
