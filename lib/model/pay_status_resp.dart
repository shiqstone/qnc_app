class PayStatusResp {
  late int statusCode;
  String? statusMsg;
  String? depositId;
  int? status;
  int? balance;
  String? result;

  PayStatusResp(this.statusCode, this.statusMsg, this.depositId, this.status,  this.balance, this.result);

  PayStatusResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    depositId = json['deposit_id'];
    status = json['status'];
    balance = json['balance'];
    result = json['result'];
  }

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status_msg': statusMsg,
        'deposit_id': depositId,
        'status': status,
        'balance': balance,
        'result': result,
      };

  static int PAY_STATUS_INIT = 0; //支付未处理
	static int PAY_STATUS_SUCCESS = 1; //支付成功
	static int PAY_STATUS_FALID = 2; //支付失败
	static int PAY_STATUS_UNKNOW = 3; //未知状态,一般是过期

}
