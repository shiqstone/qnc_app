import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qnc_app/constant.dart';

import 'package:http/http.dart' as http;
import 'package:qnc_app/model/login_resp.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/string.dart';
import 'package:qnc_app/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences sharedPreferences;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Welcome',
                        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text("It's good to have you.", style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 48.0),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Enter Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!StringUtil.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, minimumSize: Size(400, 45)),
                        onPressed: _loading ? null : _submitData,
                        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a member? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              LogUtil.d('signup ontap');
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Login now',
                              style: TextStyle(color: Colors.pinkAccent),
                            ),
                          ),
                        ],
                      ),
                      if (_loading)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    setState(() {
      _loading = true;
    });

    var url = Constant.httpBaseUrl + '/user/register/';
    LogUtil.d(url);
    var response = await http.post(Uri.parse(url), body: {
      'email': emailController.text,
      'username': emailController.text,
      'password': passwordController.text,
    });

    LogUtil.i('send reg request');
    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.body);
      var processResp = LoginResp.fromJson(respMap);
      // login success
      if (processResp.statusCode != 0) {
        showCustomToast(context, processResp.statusMsg);
      } else {
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setInt('uid', processResp.userId as int);
        sharedPreferences.setString('token', processResp.token!);

        int count = 0;
        Navigator.popUntil(context, (_) => count++ >= 2);
      }
    } else {
      LogUtil.e('Failed to submit Sign Up');
      showCustomToast(context, 'Failed to submit Sign Up');
    }

    setState(() {
      _loading = false;
    });
  }
}
