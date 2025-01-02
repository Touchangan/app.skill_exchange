import '../discovery/discover_screen.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../publish/skill_publish_screen.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentIndex = 3; // 当前页面索引为“私信”

  final List<Widget> _pages = [
    HomeScreen(),       // 首页
    DiscoveryScreen(),  // 发现
    SkillPublishScreen(),
    ChatScreen(),       // 私信
    ProfileScreen(),    // 我的
  ];

  void _onTabTapped(int index) {
    if (index != 2) { // 只在非当前页面的点击时跳转
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: '搜索消息或联系人',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // 设置功能逻辑
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 2, // 示例会话数量
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('用户名'),
            subtitle: Text('上一次的聊天消息...', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index % 2 == 0) // 示例红点逻辑
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatDetailScreen()),
              );
            },
          );
        },
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
            icon: SizedBox.shrink(), // 占位符，避免中间按钮位置重叠
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
