import 'package:flutter_riverpod/flutter_riverpod.dart';

class Post {
  final String id;
  final String userName;
  final String content;
  final DateTime timestamp;
  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.id,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });
}

class FeedNotifier extends StateNotifier<List<Post>> {
  FeedNotifier() : super(_dummyPosts());

  static List<Post> _dummyPosts() => [
    Post(
      id: '1',
      userName: 'Tausif',
      content: 'Building CampusBondhu 🚀',
      timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      likes: 12,
      comments: 3,
    ),
    Post(
      id: '2',
      userName: 'Rahim',
      content: 'Anyone up for group study tonight?',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      likes: 5,
      comments: 2,
    ),
  ];

  void toggleLike(String id) {
    state = state.map((post) {
      if (post.id == id) {
        post.isLiked = !post.isLiked;
        post.likes += post.isLiked ? 1 : -1;
      }
      return post;
    }).toList();
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, List<Post>>((ref) {
  return FeedNotifier();
});
