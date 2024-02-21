
class UserResp {
  late int statusCode;
  late String statusMsg;
  Map<String, dynamic>? user;

  UserResp(
    this.statusCode,
    this.statusMsg,
    this.user,
  );

  UserResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status_msg': statusMsg,
        'user': user,
      };
}


