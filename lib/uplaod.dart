import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class Prepare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   primaryColor: Color(0xb019937b), // 设置主题颜色
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: PreparePage(),
    );
  }
}

class PreparePage extends StatefulWidget {
  @override
  State<PreparePage> createState() => _PreparePageState();
}

class Coordinate {
  late double x;
  late double y;

  Coordinate(this.x, this.y);

  Map toJson() => {
        'x': x,
        'y': y,
      };
}

class ProcessResp {
  late String msg;
  late String processedImage;

  ProcessResp(this.msg, this.processedImage);

  ProcessResp.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    processedImage = json['processed_image'];
  }

  Map<String, dynamic> toJson() => {'msg': msg, 'processed_image': processedImage};
}

class _PreparePageState extends State<PreparePage> {
  File? _file;
  Image? _image;
  bool _loading = false;
  int? width;
  int? height;
  Uint8List? _processedImageBytes;
  bool _success = false;

  List<Coordinate> coords = [];
  List<Offset> points = [];

  void _resetPoints() {
    setState(() {
      points.clear();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
        _image = Image.file(_file!);

        _image!.image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener(
          (ImageInfo info, bool _) {
            width = info.image.width;
            height = info.image.height;
          },
        ));
      });
    }
  }

  void _submitData() async {
    setState(() {
      _loading = true;
    });

    // Replace this URL with your API endpoint
    var url = 'http://127.0.0.1/image/ud';

    // Construct form data
    var request = http.MultipartRequest('POST', Uri.parse(url));
    // Add image file
    var file = _file!;
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', stream, length, filename: 'image.jpg');
    request.files.add(multipartFile);
    // Add positions array
    request.fields['pos'] = jsonEncode(coords);

    // Send request
    var response = await request.send();

    // Check response
    if (response.statusCode == 200) {
      print('Image annotation submitted successfully');
      // print(await response.stream.bytesToString());

      Map<String, dynamic> respMap = jsonDecode(await response.stream.bytesToString());
      var processResp = ProcessResp.fromJson(respMap);
      if (processResp.processedImage.isNotEmpty) {
        setState(() {
          _success = true;
          _processedImageBytes = base64Decode(processResp.processedImage);
        });
      }
    } else {
      print('Failed to submit image annotation');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveImage() async {
    if (_processedImageBytes != null) {
      final result = await ImageGallerySaver.saveImage(_processedImageBytes!);
      print('Image saved: $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    var readyToUplod = Center(
      child: GestureDetector(
        onTap: () async {
          await _pickImage();
        },
        child: Container(
          width: 200,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xb019937b),
                width: 25.0,
              ),
            ),
            // color: Color(0xb01abc9c),
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                size: 65.0,
                color: Color(0xffffffff),
              ),
            ),
            // color: Color(0xb01abc9c),
          ),
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              // 左侧Logo
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: new Image(
                  image: new AssetImage("assets/images/logo.png"),
                  width: 30,
                  height: 30,
                ),
              ),
              Spacer(), // 空白占位
              // 右侧Avatar
              GestureDetector(
                onTap: () {
                  // TODO: 展开下拉菜单
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xb019937b),
        ),
        body: Container(
          child: _file == null
              ? readyToUplod
              : Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _success
                            ? Image.memory(
                                _processedImageBytes!,
                              )
                            : Stack(
                                children: [
                                  GestureDetector(
                                    onTapUp: (TapUpDetails details) {
                                      setState(() {
                                        if (points.length < 3) {
                                          double x = details.localPosition.dx / width!;
                                          double y = details.localPosition.dy / height!;
                                          Coordinate coord = new Coordinate(x, y);
                                          coords.add(coord);
                                          points.add(details.localPosition);
                                        }
                                      });
                                    },
                                    child: _image!,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: _resetPoints,
                                    ),
                                  ),
                                  ...points.map((point) {
                                    return Positioned(
                                      left: point.dx - 5, // Adjust based on the size of your red dot
                                      top: point.dy - 5,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                        // Image.file(_file!),
                        SizedBox(height: 10),
                        _success
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _saveImage,
                                    icon: Icon(Icons.file_download),
                                    label: Text('Save'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Color(0xffEDFCF5)),
                                      foregroundColor: MaterialStateProperty.all(Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => {
                                      setState(() {
                                        _file = null;
                                        _image = null;
                                        _success = false;
                                        _loading = false;
                                        _processedImageBytes = null;
                                      })
                                    },
                                    child: Text('Again'),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _resetPoints();
                                      setState(() {
                                        _file = null;
                                      });
                                    },
                                    icon: Icon(Icons.restart_alt),
                                    label: Text('Reset'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Color(0xffEDFCF5)),
                                      foregroundColor: MaterialStateProperty.all(Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: _loading ? null : _submitData,
                                    icon: Icon(Icons.upload),
                                    label: Text('TryOn'),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    if (_loading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
          color: Color(0xb01abc9c),
        )

        // backgroundColor: Color(0xb01abc9c),
        );
  }
}
