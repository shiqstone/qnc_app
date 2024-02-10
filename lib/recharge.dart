import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qnc_app/appbar.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';
import 'package:qnc_app/model/payment_resp.dart';
import 'package:qnc_app/payresult.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RechargePage extends StatefulWidget {
  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  // int? _selectedAmount;
  int _selectedMethod = 0;
  double _selectedAmountPrice = 0.0;
  bool _isLoading = false;

  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  // 假定这些数据是从后端接口获取的
  final List<Map<String, dynamic>> _rechargeAmounts = [
    {'amount': '10 Coins', 'price': 0.99},
    {'amount': '30 Coins', 'price': 2.97},
    {'amount': '50 Coins', 'price': 4.90},
    {'amount': '100 Coins', 'price': 9.88},
  ];

  final List<String> _paymentMethods = ['Paypal', 'Credit Card', 'Gift Code'];

  Widget _buildRechargeAmounts() {
    var cols = 2;
    var itemWidth = (MediaQuery.of(context).size.width - 30) / cols;
    var itemHeight = 55.0;
    var childAspectRatio = itemWidth / itemHeight;
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _rechargeAmounts.length,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey.withOpacity(0.4))),
          child: ListTile(
            title: Text(_rechargeAmounts[index]['amount']),
            trailing: Text(
              '\$' + _rechargeAmounts[index]['price'].toString(),
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              setState(() {
                _selectedAmountPrice = _rechargeAmounts[index]['price'];
              });
            },
            selectedColor: Colors.white,
            selected: _selectedAmountPrice == _rechargeAmounts[index]['price'],
            selectedTileColor: Colors.blueAccent.withOpacity(0.6),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: _paymentMethods.asMap().entries.map((entry) {
        int index = entry.key;
        String method = entry.value;
        return Container(
          decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.2))),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ListTile(
            title: Text(method),
            onTap: () {
              setState(() {
                _selectedMethod = index + 1;
              });
            },
            selectedColor: Colors.white,
            selected: _selectedMethod == index + 1,
            selectedTileColor: Colors.blueAccent.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QncAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildTitle('Choose Payment Amount'),
                  _buildRechargeAmounts(),
                  SizedBox(height: 15),
                  _buildTitle('Choose Payment Method'),
                  _buildPaymentMethods(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pay,
                    child: Text('Payment', style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                          return Colors.green;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('TIPS: Payment Notice'),
                ],
              ),
            ),
    );
  }

  Future<void> _pay() async {
    if (_selectedAmountPrice == 0) {
      Fluttertoast.showToast(
        msg: 'please choose payment amount',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_selectedMethod == 0) {
      Fluttertoast.showToast(
        msg: 'please choose payment method',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    if (token == null || token!.isEmpty) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var url = Constant.httpBaseUrl + '/pay/payment/';
    LogUtil.d(url);
    Map<String, String> headers = <String, String>{'Authorization': 'Bearer ' + token};
    var response = await http.post(Uri.parse(url), headers: headers, body: {
      'paytype': _selectedMethod.toString(),
      'amount': _selectedAmountPrice.toString(),
    });

    LogUtil.i('send payment request');
    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.body);
      var payResp = PaymentResp.fromJson(respMap);
      LogUtil.d(payResp);
      if (payResp.statusCode == 10003 || payResp.statusCode == 10005) {
        LogUtil.d('no login');
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      } else if (payResp.statusCode != 0) {
        Fluttertoast.showToast(
          msg: payResp.statusMsg ?? 'payment failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        if (payResp.depositId != null) {
          LogUtil.i('payment success, deposit_id: ${payResp.depositId}');
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new PaymentResultPage(
                        despositId: payResp.depositId!,
                      )));
        } else {
          Fluttertoast.showToast(
            msg: payResp.statusMsg ?? 'payment failed',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } else {
      LogUtil.e('Failed to submit payment');
      Fluttertoast.showToast(
        msg: 'Failed to submit payment',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
