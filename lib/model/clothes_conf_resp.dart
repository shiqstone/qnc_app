class ClothesConfResp {
  late int statusCode;
  String? statusMsg;
  late List<String> clothes;

  ClothesConfResp(this.statusCode, this.statusMsg, this.clothes);

  ClothesConfResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    clothes = json['clothes'].cast<String>();
  }

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status_msg': statusMsg,
        'clothes': clothes,
      };

}
