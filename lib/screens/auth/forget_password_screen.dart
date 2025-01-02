//忘记密码页面

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isCodeSent = false; // 用于切换到输入验证码和重置密码的界面

  void sendVerificationCode() {
    // 模拟验证码发送逻辑
    setState(() {
      isCodeSent = true;
    });

    // 弹出提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("验证码已发送到您的邮箱"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void resetPassword() {
    // 模拟重置密码逻辑
    String email = emailController.text.trim();
    String code = codeController.text.trim();
    String newPassword = newPasswordController.text.trim();

    if (code == "123456") {
      // 假设验证码为123456
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("密码重置成功，请重新登录"),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context); // 返回到登录页面
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("验证码错误，请重试"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('找回密码'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isCodeSent) ...[
              // 输入邮箱地址
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '邮箱地址',
                  hintText: '请输入您的邮箱...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('获取验证码'),
              ),
            ] else ...[
              // 输入验证码和新密码
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: '验证码',
                  hintText: '请输入收到的验证码...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '新密码',
                  hintText: '请输入新密码...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('重置密码'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
