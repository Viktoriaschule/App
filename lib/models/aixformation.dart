import 'package:meta/meta.dart';
import 'package:viktoriaapp/loaders/loader.dart';

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
    @required this.url,
    @required this.author,
    @required this.tags,
  });

  /// Creates a Post object from json
  factory Post.fromJSON(json) => Post(
        id: json['id'],
        date: DateTime.parse(json['date']),
        title: json['title'],
        url: json['url'],
        author: json['author'],
        tags: json['tags'].cast<String>(),
      );

  /// Creates json from a Post object
  Map<String, dynamic> toJSON() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'url': url,
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
  final String url;

  // ignore: public_member_api_docs
  final String author;

  // ignore: public_member_api_docs
  final List<String> tags;

  // ignore: public_member_api_docs
  String get imageUrl => '$baseUrl/aixformation/images/$id';
}
