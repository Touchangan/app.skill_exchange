//输入验证工具

// lib/utils/validators.dart

class Validators {
  // 验证必填字段
  static String? required(String? value) {
    return (value == null || value.isEmpty) ? '此字段不能为空' : null;
  }

  // 验证邮箱格式
  static String? email(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+\$');
    return (value == null || !emailRegex.hasMatch(value)) ? '请输入有效的邮箱地址' : null;
  }
}

