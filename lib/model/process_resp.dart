class ProcessResp {
  late String msg;
  String? processedImage;

  ProcessResp(this.msg, this.processedImage);

  ProcessResp.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    processedImage = json['processed_image'];
  }

  Map<String, dynamic> toJson() => {'msg': msg, 'processed_image': processedImage};
}