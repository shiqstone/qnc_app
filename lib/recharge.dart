import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qnc_app/appbar.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';
import 'package:qnc_app/model/deposit_conf_resp.dart';
import 'package:qnc_app/model/payment_resp.dart';
import 'package:qnc_app/payresult.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RechargePage extends StatefulWidget {
  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  String _selectedMethod = '';
  double _selectedAmountPrice = 0.0;
  bool _isLoading = false;

  late SharedPreferences sharedPreferences;

  List<Map<String, dynamic>> _rechargeAmounts = [
    {'sign': '\$', 'amount': '10 Coins', 'price': 0.98},
    {'sign': '\$', 'amount': '30 Coins', 'price': 2.97},
    {'sign': '\$', 'amount': '50 Coins', 'price': 4.96},
    {'sign': '\$', 'amount': '100 Coins', 'price': 9.85},
  ];
  // List<String> _paymentMethods = ['Paypal', 'Credit Card', 'Gift Code'];
  List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Paypal', 'id': 'paypal'},
    {'name': 'Credit Card', 'id': 'credit'},
    {'name': 'Gift Code', 'id': 'gift'}
  ];
  String _tips = "Payment Notice";

  @override
  void initState() {
    super.initState();

    getDepositConf();
  }

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
        String amount = _rechargeAmounts[index]['amount'];
        String price = (_rechargeAmounts[index]['sign'] ?? '') + _rechargeAmounts[index]['price'].toString();
        return Container(
          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey.withOpacity(0.4))),
          child: ListTile(
            title: Text(
              amount,
              style: TextStyle(fontSize: amount.length > 8 ? 13 : 15),
            ),
            trailing: Text(
              price,
              style: TextStyle(color: Colors.red, fontSize: price.length > 9 ? 13 : 15),
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
    if (_paymentMethods.length > 1) {
      return Column(
        children: _paymentMethods.map((entry) {
          // int index = entry.key;
          // String method = entry.value;
          return Container(
            decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.2))),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: ListTile(
              title: Text(entry['name']),
              onTap: () {
                setState(() {
                  _selectedMethod = entry['id'];
                });
              },
              selectedColor: Colors.white,
              selected: _selectedMethod == entry['id'],
              selectedTileColor: Colors.blueAccent.withOpacity(0.6),
            ),
          );
        }).toList(),
      );
    } else {
      setState(() {
        _selectedMethod = _paymentMethods[0]['id'];
      });
      return Column();
    }
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
                  if (_paymentMethods.length > 1) _buildTitle('Choose Payment Method'),
                  _buildPaymentMethods(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pay,
                    child: Text(
                      'Payment',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                          return Colors.green;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('TIPS: ' + _tips),
                ],
              ),
            ),
    );
  }

  Future<void> _pay() async {
    if (_selectedAmountPrice == 0) {
      showCustomToast(context, 'please choose payment amount');
      return;
    }
    if (_selectedMethod == '') {
      showCustomToast(context, 'please choose payment method');
      return;
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    if (token == null || token.isEmpty) {
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
      'paytype': _selectedMethod,
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
        showCustomToast(context, payResp.statusMsg ?? 'payment failed');
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
          showCustomToast(context, payResp.statusMsg ?? 'payment failed');
        }
      }
    } else {
      LogUtil.e('Failed to submit payment');
      showCustomToast(context, 'Failed to submit payment');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getDepositConf() async {
    var url = Constant.httpBaseUrl + '/api/getdepositprods/';
    var response = await http.get(Uri.parse(url));

    LogUtil.i('query deposit conf request');
    if (response.statusCode == 200) {
      Map<String, dynamic> respMap = jsonDecode(await response.body);
      var depositConfResp = DepositConfResp.fromJson(respMap);
      LogUtil.d(depositConfResp);
      if (depositConfResp.statusCode != 0) {
        showCustomToast(context, depositConfResp.statusMsg ?? 'query deposit config failed');
      } else {
        if (depositConfResp.products.isNotEmpty) {
          List<Map<String, dynamic>> prods = [];
          for (var prod in depositConfResp.products) {
            double price = prod["price"].toDouble();
            prods.add({"amount": prod['name'], "price": price, "sign": prod['sign']});
          }
          setState(() {
            _rechargeAmounts = prods;
          });
        }

        if (depositConfResp.payways.isNotEmpty) {
          List<Map<String, dynamic>> payways = [];
          for (var way in depositConfResp.payways) {
            payways.add(way);
          }
          setState(() {
            _paymentMethods = payways;
          });
        }
        if (depositConfResp.tips != null && depositConfResp.tips!.isNotEmpty) {
          setState(() {
            _tips = depositConfResp.tips!;
          });
        }
      }
    } else {
      LogUtil.e('Failed to query product config ');
      showCustomToast(context, 'Failed to query product config ');
    }
  }
}
