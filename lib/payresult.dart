import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';
import 'package:qnc_app/model/pay_status_resp.dart';
import 'package:qnc_app/recharge.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentResultPage extends StatefulWidget {
  final String despositId;

  PaymentResultPage({Key? key, required this.despositId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PaymentResultPageState();
  }
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  int _status = 0;
  int? _balance;

  @override
  void initState() {
    super.initState();
    pollPayStatus(widget.despositId);
  }

  // This should take a parameter to display the actual payment result
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Payment Result'),
      // ),
      body: Center(child: _buildPayStatus()),
    );
  }

  Widget _buildPayStatus() {
    switch (_status) {
      case 0:
        return Container(
          color: Colors.blue.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Payment processing, please wait...',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new RechargePage()));
                  },
                  child: Icon(Icons.highlight_off, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            Text('Payment Successful!'),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(context, new MaterialPageRoute(builder: (context) => new PrepareTryOnPage()));
                    // int count = 0;
                    // Navigator.popUntil(context, (_) => count++ >= 2);
                    Navigator.pop(context);
                    Navigator.pop(context, _balance);
                  },
                  child: Text('Back'),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return Colors.blue.withOpacity(0.3);
                    // if (states.contains(MaterialState.hovered)) {
                    // }
                    // return Colors.transparent;
                  })),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(context, new MaterialPageRoute(builder: (context) => new RechargePage()));
                    Navigator.pop(context);
                  },
                  child: Text('TopUp Again'),
                ),
              ],
            )
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.highlight_off, color: Colors.red, size: 80),
            Text('Payment Failed!'),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                // Navigator.push(context, new MaterialPageRoute(builder: (context) => new RechargePage()));
                Navigator.pop(context);
              },
              child: Icon(Icons.backspace_outlined, color: Colors.black, size: 30),
            ),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.help_outline, color: Colors.yellow, size: 80),
            Text('Payment Result Unkown'),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                // Navigator.push(context, new MaterialPageRoute(builder: (context) => new RechargePage()));
                Navigator.pop(context);
              },
              child: Icon(Icons.backspace_outlined, color: Colors.black, size: 30),
            ),
          ],
        );
    }
  }

  Future<void> pollPayStatus(String despositId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    if (token == null || token.isEmpty) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      return;
    }

    var url = Constant.httpBaseUrl + '/pay/status/';
    LogUtil.d(url);
    Map<String, String> headers = <String, String>{'Authorization': 'Bearer ' + token};
    var response = await http.post(Uri.parse(url), headers: headers, body: {
      'deposit_id': widget.despositId,
    });

    LogUtil.i('send payment status request');
    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.body);
      var payResp = PayStatusResp.fromJson(respMap);
      LogUtil.d(payResp);
      if (payResp.statusCode == 10003 || payResp.statusCode == 10005) {
        LogUtil.d('no login');
        return;
      } else if (payResp.statusCode != 0) {
        showCustomToast(context, payResp.statusMsg ?? 'query payment status failed');
      } else {
        //pay success
        setState(() {
          _status = payResp.status!;
          _balance = payResp.balance;
        });
        if (_status == 0) {
          Future.delayed(const Duration(milliseconds: 3000), () {
            pollPayStatus(widget.despositId);
          });
        }
      }
    } else {
      LogUtil.e('Failed to query payment status');
      showCustomToast(context, 'Failed to query payment status');
    }
  }
}
