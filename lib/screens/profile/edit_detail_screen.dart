import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;

  EditProfileScreen({required this.userId}); // 接收用户 ID

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _accountController = TextEditingController(); // 新增账号名输入框控制器
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _gender;
  DateTime? _birth;
  String? _avatarUrl; // 动态存储头像 URL
  File? _avatarFile; // 存储选中的头像文件
  bool _isLoading = true; // 加载状态

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // 获取用户信息
  Future<void> _fetchUserInfo() async {
    final url = Uri.parse("http://120.46.200.190:5500/api/users/${widget.userId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _accountController.text = data['account'] ?? ''; // 设置账号名
          _schoolController.text = data['school'] ?? '';
          _profileController.text = data['profile'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _gender = data['gender'];
          _birth = data['birth'] != null ? DateTime.parse(data['birth']) : null;
          _avatarUrl = data['avator']; // 动态设置头像 URL
          _isLoading = false; // 加载完成
        });
      } else {
        print("获取用户信息失败: ${response.body}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("请求错误: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 更新用户头像
  Future<void> _updateUserAvatar() async {
    if (_avatarFile == null) return; // 如果没有选择头像，则跳过

    final url = Uri.parse("http://120.46.200.190:5500/api/users/${widget.userId}/avatar");
    try {
      // 读取头像文件并转换为 Base64
      final imageBytes = await _avatarFile!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"avatar_base64": base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _avatarUrl = data['avatar_url']; // 更新头像 URL
        });
        print("头像更新成功: ${data['avatar_url']}");
      } else {
        print("头像更新失败: ${response.body}");
        _showErrorDialog("头像更新失败，请重试！");
      }
    } catch (e) {
      print("网络错误: $e");
      _showErrorDialog("网络错误，请检查网络连接！");
    }
  }

  Future<void> _updateUserInfo() async {
    await _updateUserAvatar(); // 先更新头像

    final url = Uri.parse("http://120.46.200.190:5500/api/users/${widget.userId}/info");

    final body = {
      "account": _accountController.text, // 账号名
      "school": _schoolController.text,
      "profile": _profileController.text,
      "phone": _phoneController.text,
      "gender": _gender,
      "birth": _birth?.toIso8601String(),
    };
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // 返回时传递一个标志（true）通知主页刷新
        Navigator.pop(context, true);
      } else {
        print("更新用户信息失败: ${response.body}");
        _showErrorDialog("更新失败，请重试！");
      }
    } catch (e) {
      print("更新错误: $e");
      _showErrorDialog("网络错误，请检查网络连接！");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("编辑个人资料", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _updateUserInfo, // 保存个人信息逻辑
            child: Text("保存", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // 用户头像
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _avatarFile = File(pickedFile.path); // 设置选中的本地头像文件
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!) // 显示本地头像
                        : (_avatarUrl != null
                        ? NetworkImage(_avatarUrl!) // 显示后端加载的头像 URL
                        : null),
                    child: (_avatarFile == null && _avatarUrl == null)
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                Icon(Icons.camera_alt, color: Colors.grey),
              ],
            ),
          ),
          Divider(),
          // 账号名输入框
          ListTile(
            title: Text("用户名"),
            subtitle: TextField(
              controller: _accountController,
              decoration: InputDecoration(hintText: "请输入用户名"),
            ),
          ),
          // 个人信息表单
          ListTile(
            title: Text("学校"),
            subtitle: TextField(
              controller: _schoolController,
              decoration: InputDecoration(hintText: "请输入学校名称"),
            ),
          ),
          ListTile(
            title: Text("简介"),
            subtitle: TextField(
              controller: _profileController,
              decoration: InputDecoration(hintText: "请输入个人简介"),
            ),
          ),
          ListTile(
            title: Text("手机号"),
            subtitle: TextField(
              controller: _phoneController,
              decoration: InputDecoration(hintText: "请输入手机号"),
            ),
          ),
          ListTile(
            title: Text("性别"),
            trailing: DropdownButton<String>(
              value: _gender,
              items: ["male", "female", "other"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text("生日"),
            trailing: TextButton(
              child: Text(_birth != null
                  ? _birth!.toLocal().toString().split(' ')[0]
                  : "选择生日"),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _birth ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _birth) {
                  setState(() {
                    _birth = picked;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
