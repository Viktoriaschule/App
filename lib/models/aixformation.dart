import 'package:meta/meta.dart';

/// AiXformation class
/// describes all posts
class AiXformation {
  // ignore: public_member_api_docs
  AiXformation({
    @required this.posts,
    @required this.date,
  });

  /// Creates a AiXformation object from json
  factory AiXformation.fromJSON(json) => AiXformation(
        posts: json['posts'].map((i) => Post.fromJSON(i)).toList().cast<Post>(),
        date: DateTime.parse(json['date']),
      );

  /// Creates json from a AiXformation object
  Map<String, dynamic> toJSON() => {
        'posts': posts.map((i) => i.toJSON()).toList(),
        'date': date.toIso8601String(),
      };

  /// Get the time stamp of this object
  int get timeStamp => date.millisecondsSinceEpoch ~/ 1000;

  // ignore: public_member_api_docs
  final List<Post> posts;

  // ignore: public_member_api_docs
  final DateTime date;
}

/// Post class
/// describes one post
class Post {
  // ignore: public_member_api_docs
  Post({
    @required this.id,
    @required this.date,
    @required this.title,
    @required this.content,
    @required this.url,
    @required this.thumbnailUrl,
    @required this.mediumUrl,
    @required this.fullUrl,
    @required this.author,
    @required this.tags,
  });

  /// Creates a Post object from json
  factory Post.fromJSON(json) => Post(
        id: json['id'],
        date: DateTime.parse(json['date']),
        title: json['title'],
        content: json['content'],
        url: json['url'],
        thumbnailUrl: json['thumbnailUrl'],
        mediumUrl: json['mediumUrl'],
        fullUrl: json['fullUrl'],
        author: json['author'],
        tags: json['tags'].cast<String>(),
      );

  /// Creates json from a Post object
  Map<String, dynamic> toJSON() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'mediumUrl': mediumUrl,
        'fullUrl': fullUrl,
        'author': author,
        'tags': tags,
      };

  // ignore: public_member_api_docs
  final int id;

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final String content;

  // ignore: public_member_api_docs
  final String url;

  // ignore: public_member_api_docs
  final String thumbnailUrl;

  // ignore: public_member_api_docs
  final String mediumUrl;

  // ignore: public_member_api_docs
  final String fullUrl;

  // ignore: public_member_api_docs
  final String author;

  // ignore: public_member_api_docs
  final List<String> tags;
}
