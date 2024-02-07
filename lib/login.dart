import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/signup.dart';
import 'package:http/http.dart' as http;
import 'package:qnc_app/model/login_resp.dart';
import 'package:qnc_app/uplaod.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences sharedPreferences;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
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
                        'Hello',
                        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                      ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: Size(400, 45)),
                        onPressed: _loading ? null : _submitData,
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Not a member? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, '/signup'); // Assuming you have a named route for sign up
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new SignUpPage()));
                            },
                            child: Text(
                              'Signup now',
                              style: TextStyle(color: Colors.blueAccent),
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

    var url = Constant.httpBaseUrl + '/user/login/';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    var response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.stream.bytesToString());
      var processResp = LoginResp.fromJson(respMap);
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
