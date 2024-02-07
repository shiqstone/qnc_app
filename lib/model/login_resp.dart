class LoginResp {
  late int statusCode;
  late String statusMsg;
  int? userId;
  String? token;

  LoginResp(this.statusCode, this.statusMsg, this.userId, this.token);

  LoginResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    userId = json['user_id'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() => {
    'status_code': statusCode, 
    'status_msg': statusMsg, 
    'user_id': userId, 
    'token': token};
}
