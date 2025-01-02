//lib/models/experience_post.dart

class ExperiencePost {
  final String user;
  final String date;
  final String location;
  final String contentTitle;
  final List<String> contentSummary;
  final String imageUrl;
  final int likes;
  final int comments;
  final int favorites;

  ExperiencePost({
    required this.user,
    required this.date,
    required this.location,
    required this.contentTitle,
    required this.contentSummary,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.favorites,
  });
}
