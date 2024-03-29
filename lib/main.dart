import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test_01/reddit_response.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:build_variants/build_variants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _success = true;
  String _after;
  List<Post> _posts = [];
  bool _loading = false;
  String _flavor;
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _loadData();
    _loadFlavor();
  }

  _scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      _handleRefresh();
    }
  }

  Future<Null> _loadData() async {
    _after = null;
    _posts.clear();
    _handleRefresh();
  }

  Future<Null> _handleRefresh() async {
    try {
      setState(() {
        _loading = true;
      });

      final response = await _fetchPosts();
      setState(() {
        _posts = _posts + response.data.children;
        _counter = _posts.length;
        _after = response.data.after;
        _success = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _success = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<RedditResponse> _fetchPosts() async {
    final response =
        await get('https://www.reddit.com/r/Android/new/.json?after=$_after');

    if (response.statusCode == 200) {
      return RedditResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} ($_flavor)"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_success ? 'Posts: ' : 'Ocorreu um erro'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildTile(_posts[index]);
                  },
                ),
              ),
            ),
            Visibility(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              visible: _loading,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildTile(Post post) {
    final hasUrl = post.thumbnail.startsWith("http");
    final image = hasUrl
        ? NetworkImage(
            post.thumbnail,
          )
        : AssetImage("assets/images/reddit-icon.png");

    return ListTile(
      leading: Container(
        width: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: image),
        ),
      ),
      title: Text(post.title),
      subtitle: Text('${post.ups}'),
      onTap: () {
        _launchURL(post.url);
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _loadFlavor() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BuildVariants.getVariant;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _flavor = platformVersion;
    });
  }
}
