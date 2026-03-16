class Activity {
  final int? id;
  final String title;
  final String? summary;
  final String content;
  final String? imageUrl;
  final String? startTime;
  final String? location;
  final bool isFeatured;
  final String? createdAt;

  Activity({
    this.id, 
    required this.title, 
    this.summary, 
    required this.content, 
    this.imageUrl, 
    this.startTime, 
    this.location, 
    this.isFeatured = false,
    this.createdAt
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'] ?? 'Không có tiêu đề',
      summary: json['summary'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      startTime: json['start_time'],
      location: json['location'],
      isFeatured: json['is_featured'] ?? false,
      createdAt: json['created_at'],
    );
  }
}