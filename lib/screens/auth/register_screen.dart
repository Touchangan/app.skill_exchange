import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _handleRegister(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("注册失败"),
          content: Text("两次输入的密码不一致"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("确定"),
            ),
          ],
        ),
      );
      return;
    }

    final success = await AuthService.register(email: email, password: password);

    if (success) {
      // 注册成功，显示提示框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("注册成功"),
          content: Text("注册成功，请返回登录页面"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭提示框
                Navigator.pop(context); // 返回登录页面
              },
              child: Text("确定"),
            ),
          ],
        ),
      );
    } else {
      // 注册失败，显示错误提示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("注册失败"),
          content: Text("注册失败，请重试"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("确定"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "邮箱"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "密码"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "确认密码"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleRegister(context),
              child: Text("注册"),
            ),
          ],
        ),
      ),
    );
  }
}
