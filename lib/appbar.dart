import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qnc_app/main.dart';
import 'package:qnc_app/model/user_resp.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';

class QncAppBar extends AppBar {

  @override
  State<QncAppBar> createState() => _QncAppBarState();
}

class _QncAppBarState extends State<QncAppBar> {
  late String _username = '';
  late int _balance = 0;
  String? token;

  @override
  void initState() {
    super.initState();

    _queryUserInfo();
  }

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new MyApp()));
            },
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                width: 30,
                height: 30,
              ),
            ),
          ),
          Spacer(),
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  // Handle avatar tap
                  final RenderBox button = context.findRenderObject()! as RenderBox;
                  final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
                  Offset offset = Offset(0.0, button.size.height + 10);

                  RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(offset, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );
                  showMenu(
                    context: context,
                    position: position,
                    constraints: BoxConstraints(maxHeight: 315, maxWidth: 200),
                    items: [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _username,
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'balance',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Balance: ', textAlign: TextAlign.right),
                            Text(_balance.toString(), textAlign: TextAlign.right, style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Sign out', textAlign: TextAlign.right),
                          ],
                        ),
                        onTap: () async {
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                          sharedPreferences.remove('token');
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
                        },
                      ),
                    ],
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: _username.isEmpty
                      ? CircleAvatar(
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        )
                      : Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _username.isNotEmpty ? _username[0].toUpperCase() : '',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xb019937b),
    );
  }

  Future<void> _queryUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    if (token == null || token!.isEmpty) {
      // Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      return;
    }

    var url = Constant.httpBaseUrl + '/user/';
    var request = http.MultipartRequest('GET', Uri.parse(url));
    Map<String, String> headers = <String, String>{'Authorization': 'Bearer ' + token!};
    request.headers.addAll(headers);
    var response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.stream.bytesToString());
      var userResp = UserResp.fromJson(respMap);
      // query success
      if (userResp.statusCode == 10003 || userResp.statusCode == 10005) {
        LogUtil.d('no login');
        // Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      } else {
        if (userResp.user != null) {
          setState(() {
            _username = userResp.user!['user_name'];
            _balance = userResp.user!['coin'];
          });
        }
      }
    } else {
      LogUtil.e('Failed to query user info');
    }
  }
}
