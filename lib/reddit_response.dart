class RedditResponse {
  final RedditData data;

  RedditResponse(this.data);

  factory RedditResponse.fromJson(Map<String, dynamic> json) {
    return RedditResponse(RedditData.fromJson(json['data']));
  }
}

class RedditData {
  final List<Post> children;
  final String after;

  RedditData({this.children, this.after});

  factory RedditData.fromJson(Map<String, dynamic> json) {
    final list = json['children'] as List;
    final items = list.map((dynamic item) {
      return Post.fromJson(item['data']);
    }).toList();
    return RedditData(children: items, after: json['after']);
  }
}

class Post {
  final String title;
  final int ups;
  final String thumbnail;
  final String url;

  Post({this.title, this.ups, this.thumbnail, this.url});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        title: json['title'],
        ups: json['ups'],
        thumbnail: json['thumbnail'],
        url: json['url']);
  }
}
