import 'dart:convert';

// 定义 SkillPost 数据模型
class SkillPost {
  final String id;
  final String userId;
  final String type;
  final String date;
  final String contentText;
  final List<String> contentImages;
  final int commentCount;

  SkillPost({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.contentText,
    required this.contentImages,
    required this.commentCount,
  });

  factory SkillPost.fromJson(Map<String, dynamic> json) {
    return SkillPost(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      date: json['date'],
      contentText: json['contentText'],
      contentImages: List<String>.from(json['contentImages'] ?? []),
      commentCount: json['commentCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'date': date,
      'contentText': contentText,
      'contentImages': contentImages,
      'commentCount': commentCount,
    };
  }
}
