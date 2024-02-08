class ProcessResp {
  late int statusCode;
  String? statusMsg;
  String? processedImage;
  int? orderId;

  ProcessResp(this.statusCode, this.statusMsg, this.processedImage, this.orderId);

  ProcessResp.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    statusMsg = json['status_msg'];
    processedImage = json['processed_image'];
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    'status_msg': statusMsg, 
    'processed_image': processedImage,
    'order_id': orderId
    };
}
