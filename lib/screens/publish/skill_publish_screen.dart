import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'share_publish_screen.dart'; // 添加 image_picker 包

class SkillPublishScreen extends StatefulWidget {
  @override
  _SkillPublishScreenState createState() => _SkillPublishScreenState();
}

class _SkillPublishScreenState extends State<SkillPublishScreen> {
  final TextEditingController _contentController = TextEditingController();
  List<File> _images = []; // 存储选中的本地图片
  bool isSubmitting = false; // 发布按钮状态
  Map<String, dynamic>? userInfo; // 存储用户信息

  // 获取本地存储的用户ID
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // 获取用户信息
  Future<void> _fetchUserInfo() async {
    final userId = await _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("用户未登录")));
      return;
    }

    final url = Uri.parse("http://120.46.200.190:5500/api/users/$userId");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(utf8.decode(response.bodyBytes)); // 确保支持中文
        });
      } else {
        print("获取用户信息失败: ${response.body}");
      }
    } catch (e) {
      print("网络错误: $e");
    }
  }

  // 打开相册选择图片
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path)); // 将选中的图片添加到 _images 列表
      });
    }
  }

  // 提交数据到后端
  Future<void> _submitPost() async {
    final userId = await _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("用户未登录")));
      return;
    }

    // 将图片转换为 Base64 字符串
    List<String> imageBase64List = [];
    for (var image in _images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);
      imageBase64List.add(base64String);
    }

    final skillContent = {
      "content": _contentController.text,
      "images": imageBase64List, // 将 Base64 编码后的图片传递给后端
    };

    final postData = {
      "user_id": userId,
      "skill_content": skillContent, // 转换为 JSON 格式
      "skill_date": DateTime.now().toIso8601String(), // 当前时间
    };

    setState(() {
      isSubmitting = true;
    });

    final url = Uri.parse("http://120.46.200.190:5500/api/skills");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("发布成功")));
        Navigator.pop(context); // 返回上一页面
      } else {
        print("发布失败: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("发布失败，请稍后再试")));
      }
    } catch (e) {
      print("网络错误: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("网络错误")));
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 初始化时获取用户信息
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("发布技能交换"),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz), // 切换按钮
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SharePublishScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: userInfo != null && userInfo!['avator'] != null
                      ? NetworkImage(userInfo!['avator']) // 显示用户头像
                      : null,
                  child: userInfo == null || userInfo!['avator'] == null
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 8),
                Text(userInfo != null ? userInfo!['account'] ?? "用户名" : "加载中...",
                    style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "说你想说的...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue),
                  onPressed: _pickImage, // 打开相册选择图片
                ),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(_images[index], width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitPost,
              child: isSubmitting ? CircularProgressIndicator() : Text("发布"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
