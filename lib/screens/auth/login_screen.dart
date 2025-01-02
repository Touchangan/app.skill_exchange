import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart'; // 登录成功后跳转的主页
import 'register_screen.dart'; // 注册页面
import 'forget_password_screen.dart'; // 忘记密码页面

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool isPhoneLogin = false; // 默认邮箱登录
  late AnimationController _controller;
  late Animation<Offset> _emailAnimation;
  late Animation<Offset> _phoneAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _emailAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.0), // 默认起始位置
      end: Offset(-1.0, 0.0), // 滑出屏幕左侧
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _phoneAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // 从屏幕右侧滑入
      end: Offset(0.0, 0.0), // 最终位置
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleLoginMethod() {
    setState(() {
      isPhoneLogin = !isPhoneLogin;
      if (isPhoneLogin) {
        _controller.forward(); // 切换到手机号登录
      } else {
        _controller.reverse(); // 切换到邮箱登录
      }
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final success = await AuthService.login(email: email, password: password);

    if (success) {
      // 登录成功，跳转到主页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // 登录失败，显示错误提示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("登录失败"),
          content: Text("请检查邮箱和密码是否正确"),
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
        title: Text(
          '欢迎回来～',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 邮箱登录页面
          SlideTransition(
            position: _emailAnimation,
            child: Visibility(
              visible: !isPhoneLogin, // 当切换到手机号登录时隐藏
              child: _buildEmailLogin(),
            ),
          ),
          // 手机号登录页面
          SlideTransition(
            position: _phoneAnimation,
            child: Visibility(
              visible: isPhoneLogin, // 当切换到邮箱登录时隐藏
              child: _buildPhoneLogin(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController, // 添加控制器
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: '请输入邮箱账号...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController, // 添加控制器
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                  );
                },
                child: Text('忘记密码？'),
              ),
              TextButton(
                onPressed: toggleLoginMethod,
                child: Text('切换至手机号登录'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleLogin, // 替换为实际登录逻辑
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('登录', style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
            child: Text('注册账号'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLogin() {
    // 保留手机号登录逻辑，不作改动
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                  );
                },
                child: Text('忘记密码？'),
              ),
              TextButton(
                onPressed: toggleLoginMethod,
                child: Text('切换至邮箱登录'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {}, // 留空
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('登录', style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
            child: Text('注册账号'),
          ),
        ],
      ),
    );
  }
}
