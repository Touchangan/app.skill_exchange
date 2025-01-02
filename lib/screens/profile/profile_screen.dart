import '../home/home_screen.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';
import '../discovery/discover_screen.dart';
import '../publish/skill_publish_screen.dart';
import 'edit_detail_screen.dart';
import '../auth/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? userId; // 当前用户ID
  Map<String, dynamic>? userInfo; // 用户信息
  List<Map<String, dynamic>>? userPosts; // 用户帖子
  bool isLoading = true; // 加载状态
  int _currentIndex = 4; // 当前选中的导航栏索引

  final List<Widget> _pages = [
    HomeScreen(),
    DiscoveryScreen(),
    SkillPublishScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index != 2) {
      // 中间的 "发布" 按钮不在这里处理
      setState(() {
        _currentIndex = index;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // 从本地存储中获取用户ID
    userId = await AuthService.getUserId();
    if (userId != null) {
      // 获取用户信息和帖子
      await _fetchUserData(userId!);
    } else {
      // 未登录状态，返回登录页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> _fetchUserData(int userId) async {
    final userUrl = Uri.parse("http://120.46.200.190:5500/api/users/$userId");
    final postsUrl = Uri.parse("http://120.46.200.190:5500/api/skills/$userId");
    try {
      // 并发请求用户信息和帖子信息
      final userResponse = await http.get(userUrl);
      final postsResponse = await http.get(postsUrl);

      if (userResponse.statusCode == 200) {
        userInfo = json.decode(utf8.decode(userResponse.bodyBytes));
      } else {
        print("获取用户信息失败: ${userResponse.body}");
      }

      if (postsResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(postsResponse.bodyBytes));
        userPosts = List<Map<String, dynamic>>.from(data['posts']);
      } else {
        print("获取用户帖子失败: ${postsResponse.body}");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("网络错误: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("确认退出登录"),
          content: Text("您确定要退出登录吗？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("确认"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService.logout(); // 调用登出逻辑
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("用户主页"),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("用户主页"),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: Text("无法加载用户信息，请稍后重试")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("用户主页", style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "logout") {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "logout",
                child: Text("退出登录"),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 用户信息部分
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: userInfo!['avator'] != null
                          ? NetworkImage(userInfo!['avator'])
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: userInfo!['avator'] == null
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userInfo!['account'] ?? "未知用户",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${userInfo!['email']}", // 移除@符号
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userId: userId!),
                        ),
                      );
                      // 如果返回值是 true，刷新用户数据
                      if (shouldRefresh == true) {
                        _fetchUserData(userId!);
                      }
                    },
                    child: Text("编辑个人资料"),
                  ),
                ],
              ),
            ),
            Divider(),
            // 用户帖子部分
            if (userPosts != null && userPosts!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: userPosts!.length,
                itemBuilder: (context, index) {
                  final post = userPosts![index];
                  final skillContent = jsonDecode(post['skill_content']);
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skillContent['content'] ?? "无内容",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          skillContent['images'] != null &&
                              skillContent['images'].isNotEmpty
                              ? Image.network(
                            skillContent['images'][0],
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
                                  Icon(Icons.favorite, size: 16, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text("${post['skill_likes']}"),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.comment, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text("${post['skill_comment_count']}"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Center(child: Text("暂无发布内容")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 跳转到发布页面
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
