import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://120.46.200.190:5500/api";

  // 登录接口
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("登录成功: 用户ID = ${data['user_id']}");

      // 保存用户登录状态和信息到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', data['user_id']); // 保存用户ID
      await prefs.setString('email', data['email']); // 保存用户邮箱
      await prefs.setBool('isLoggedIn', true); // 保存登录状态

      return true;
    } else {
      print("登录失败: ${response.body}");
      return false;
    }
  }

  // 注册接口
  static Future<bool> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      print("注册成功");
      return true;
    } else {
      print("注册失败: ${response.body}");
      return false;
    }
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // 获取保存的用户ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // 获取用户ID
  }

  // 获取保存的用户邮箱
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email'); // 获取用户邮箱
  }

  // 登出（清除所有本地存储数据）
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有本地存储
    print("已登出并清除本地存储");
  }
}
