class PaymentResp {
  late int statusCode;
  String? statusMsg;
  String? depositId;

  PaymentResp(this.statusCode, this.statusMsg, this.depositId);

  PaymentResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    depositId = json['deposit_id'];
  }

  Map<String, dynamic> toJson() => {
    'status_code': statusCode, 
    'status_msg': statusMsg, 
    'deposit_id': depositId, 
    };
}
