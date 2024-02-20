class DepositConfResp {
  late int statusCode;
  String? statusMsg;
  late List<Map<String, dynamic>> products;
  String? tips;

  DepositConfResp(this.statusCode, this.statusMsg, this.products, this.tips);

  DepositConfResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    products = json['products'].cast<Map<String, dynamic>>();
    tips = json['tips'];
  }

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status_msg': statusMsg,
        'products': products,
        'tips': tips,
      };
}
