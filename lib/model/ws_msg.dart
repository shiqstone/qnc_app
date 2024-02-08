class WsMsg {
  late int code;
  late String msg;
  String? msgType;
  String? data;

  WsMsg(this.code, this.msg, this.msgType, this.data);

  WsMsg.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    msgType = json['msg_type'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() => {
    'code': code, 
    'msg': msg, 
    'msg_type': msgType, 
    'data': data};
}
