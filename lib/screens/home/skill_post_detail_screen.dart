import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SkillPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post; // 帖子内容
  final String? userName; // 发布者用户名
  final String? userAvatar; // 发布者头像
  final int oppositeId; // 当前登录用户ID

  SkillPostDetailScreen({
    required this.post,
    required this.userName,
    required this.userAvatar,
    required this.oppositeId,
  });

  @override
  _SkillPostDetailScreenState createState() => _SkillPostDetailScreenState();
}

class _SkillPostDetailScreenState extends State<SkillPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController(); // 评论输入框控制器

  // 获取保存的用户ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // 获取用户ID
  }

  // 确定技能交换逻辑
  Future<void> _confirmExchange(BuildContext context, int skillId, int oppositeId) async {
    final currentUserId = await getUserId();
    if (currentUserId == null) {
      _showErrorDialog("用户未登录，请登录后重试！");
      return;
    }

    if (currentUserId == oppositeId) {
      _showErrorDialog("无法与自己确定技能交换关系！");
      return;
    }

    final url = Uri.parse("http://120.46.200.190:5500/api/skills/$skillId/exchange");
    final body = {
      "skill_id": skillId,
      "user_id": currentUserId,
      "opposite_id": oppositeId,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("技能交换已成功确定！");
      } else {
        _showErrorDialog("技能交换失败，请稍后重试！");
      }
    } catch (e) {
      _showErrorDialog("网络错误，请检查网络连接！");
    }
  }

  // 提交评论
  Future<void> _submitComment(int skillId) async {
    final currentUserId = await getUserId();
    if (currentUserId == null) {
      _showErrorDialog("用户未登录，请登录后重试！");
      return;
    }

    final commentContent = _commentController.text.trim();
    if (commentContent.isEmpty) {
      _showErrorDialog("评论内容不能为空！");
      return;
    }

    final url = Uri.parse("http://120.46.200.190:5500/api/skills/$skillId/comments");
    final body = {
      "user_id": currentUserId,
      "skill_id": skillId,
      "comment_content": commentContent,
      "parent_id": null, // 默认不支持嵌套评论
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _commentController.clear(); // 清空输入框
        });
        _showSuccessDialog("评论成功！");
      } else {
        _showErrorDialog("评论失败，请稍后重试！");
      }
    } catch (e) {
      _showErrorDialog("网络错误，请检查网络连接！");
    }
  }

  // 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("错误"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("确定"),
          ),
        ],
      ),
    );
  }

  // 显示成功对话框
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("成功"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // 刷新页面
            },
            child: Text("确定"),
          ),
        ],
      ),
    );
  }

  // 获取评论数据
  Future<List<Map<String, dynamic>>> _fetchComments(int skillId) async {
    final url = Uri.parse("http://120.46.200.190:5500/api/skills/$skillId/comments");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return List<Map<String, dynamic>>.from(data["comments"]);
      } else {
        return [];
      }
    } catch (e) {
      print("加载评论失败: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final postContent = post["content"]; // 帖子内容
    final postDate = post["skill_date"]; // 帖子日期
    final postImage = post["image"]; // 帖子图片
    final skillId = post["skill_id"]; // 帖子 ID

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.userAvatar != null
                  ? NetworkImage(widget.userAvatar!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: widget.userAvatar == null
                  ? Icon(Icons.person, size: 16, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 8),
            Text(
              widget.userName ?? "未知用户",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _confirmExchange(context, skillId, widget.oppositeId);
            },
            child: Text(
              "确定交换",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '帖子详细内容：',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text('内容：$postContent'),
                        Text('日期：$postDate'),
                      ],
                    ),
                  ),
                  postImage != null
                      ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      postImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : SizedBox.shrink(),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '评论区：',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchComments(skillId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("加载评论失败"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("暂无评论"));
                      }

                      final comments = snapshot.data!;
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment["avatar"] != null
                                  ? NetworkImage(comment["avatar"])
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: comment["avatar"] == null
                                  ? Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            title: Text(comment["account"] ?? "未知用户"),
                            subtitle: Text(comment["content"]),
                            trailing: Text(
                              comment["date"].substring(0, 10),
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          // 添加评论输入框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "发表评论...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _submitComment(skillId),
                  child: Text("发送"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
