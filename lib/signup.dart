import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';

import 'package:http/http.dart' as http;
import 'package:qnc_app/model/login_resp.dart';
import 'package:qnc_app/uplaod.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/string.dart';
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
                              // Navigator.pushNamed(context, '/login'); // Assuming you have a named route for login
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
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
      'password': passwordController.text,
    });
    // var request = http.Request('POST', Uri.parse(url));
    // request.fields['email'] = emailController.text;
    // request.fields['password'] = passwordController.text;
    // var response = await request.send();

    LogUtil.i('send reg request');
    LogUtil.d(response);
    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.body);
      var processResp = LoginResp.fromJson(respMap);
      LogUtil.d(processResp);
      // login success
      if (processResp.statusCode != 0) {
        Fluttertoast.showToast(
          msg: processResp.statusMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setInt('uid', processResp.userId as int);
        sharedPreferences.setString('token', processResp.token!);

        Navigator.push(context, new MaterialPageRoute(builder: (context) => new PreparePage()));
      }
    } else {
      LogUtil.e('Failed to submit Sign Up');
      Fluttertoast.showToast(
        msg: 'Failed to submit Sign Up',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      _loading = false;
    });
  }
}
