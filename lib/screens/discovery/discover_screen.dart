import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../publish/skill_publish_screen.dart';
import '../profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import 'share_post_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int _currentIndex = 1; // 当前选中的导航栏索引，默认为“发现”页面
  List<dynamic> posts = []; // 存储帖子数据
  Map<int, dynamic> userCache = {}; // 用户信息缓存
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts(); // 初始化时获取帖子数据
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // 获取分享帖数据
  Future<void> fetchPosts() async {
    final url = Uri.parse("http://120.46.200.190:5500/api/share_posts");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // 防止中文乱码
        setState(() {
          posts = data["posts"];
        });
        await fetchUsersForPosts(); // 加载用户信息
      } else {
        print("加载帖子失败: ${response.body}");
      }
    } catch (e) {
      print("网络错误: $e");
    }
  }

  // 根据 user_id 获取用户信息
  Future<void> fetchUsersForPosts() async {
    for (var post in posts) {
      final userId = post["user_id"];
      if (!userCache.containsKey(userId)) {
        final userInfo = await fetchUserInfo(userId);
        if (userInfo != null) {
          setState(() {
            userCache[userId] = userInfo;
          });
        }
      }
    }
    setState(() {
      isLoading = false; // 数据加载完成
    });
  }

  // 调用现有用户信息接口
  Future<Map<String, dynamic>?> fetchUserInfo(int userId) async {
    final url = Uri.parse("http://120.46.200.190:5500/api/users/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("获取用户信息失败: ${response.body}");
      }
    } catch (e) {
      print("网络错误: $e");
    }
    return null;
  }

  final List<Widget Function(BuildContext)> _pages = [
        (context) => HomeScreen(),
        (context) => DiscoveryScreen(),
        (context) => SkillPublishScreen(),
        (context) => ChatScreen(),
        (context) => ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // 跳转到发布页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SkillPublishScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: _pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: '请输入搜索内容',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 显示加载动画
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加“经验分享广场”标题
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '经验分享广场：',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 动态帖子列表
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final userId = post["user_id"];
                final userInfo = userCache[userId];
                final userName = userInfo != null ? userInfo["account"] : "未知用户";
                final userAvatar = userInfo != null ? userInfo["avator"] : null;
                final shareId = post["share_id"];

                return GestureDetector(
                  onTap: () {
                    // 跳转到帖子详情页，传递 post 数据和发布者信息
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SharePostDetailScreen(
                          post: post,
                          userName: userName, // 传递用户名
                          userAvatar: userAvatar, // 传递头像
                          oppositeId: userId,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: userAvatar != null
                                    ? NetworkImage(userAvatar)
                                    : null,
                                backgroundColor: Colors.grey[300],
                                child: userAvatar == null
                                    ? Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    post["share_date"].substring(0, 10),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(post["content"], style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          post["image"] != null
                              ? Image.network(
                            post["image"],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : SizedBox.shrink(),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // 点赞逻辑（可以忽略）
                                    },
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${post["share_likes"] ?? 0}', // 显示点赞数量
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  // 评论功能逻辑（待实现）
                                },
                                icon: Icon(Icons.comment),
                              ),
                              IconButton(
                                onPressed: () {
                                  // 分享功能逻辑（待实现）
                                },
                                icon: Icon(Icons.share),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SkillPublishScreen()),
          );
        },
        child: Icon(Icons.add, size: 32),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '私信',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
