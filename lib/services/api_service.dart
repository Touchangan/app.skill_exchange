//后端API请求的封装
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://120.46.200.190:5500/api";

  // 获取用户信息
  static Future<Map<String, dynamic>?> fetchUserInfo(int userId) async {
    final url = Uri.parse("$baseUrl/users/$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print("获取用户信息失败: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("获取用户信息错误: $e");
      return null;
    }
  }

  // 获取用户发布的技能交换帖子
  static Future<List<dynamic>> fetchUserSkills(int userId) async {
    final url = Uri.parse("$baseUrl/skills?userId=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print("获取技能交换帖子失败: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("获取技能交换帖子错误: $e");
      return [];
    }
  }
}
