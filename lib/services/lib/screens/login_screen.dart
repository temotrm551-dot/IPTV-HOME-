import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/iptv_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final service = IPTVService(
      serverUrl: _urlController.text.trim(),
      username: _userController.text.trim(),
      password: _passController.text.trim(),
    );

    bool isValid = await service.authenticate();
    setState(() => _isLoading = false);

    if (isValid) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('url', _urlController.text.trim());
      await prefs.setString('username', _userController.text.trim());
      await prefs.setString('password', _passController.text.trim());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(service: service)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بيانات الاشتراك غير صحيحة أو السيرفر لا يستجيب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تطبيق IPTV', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _urlController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'رابط السيرفر (Host/URL)', labelStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: _userController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'اسم المستخدم', labelStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: _passController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'كلمة السر', labelStyle: TextStyle(color: Colors.grey)),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: Size(double.infinity, 50)),
                      child: Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
