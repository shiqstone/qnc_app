import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:qnc_app/model/coordinate.dart';
import 'package:qnc_app/model/process_resp.dart';

class PreparePage extends StatefulWidget {
  @override
  State<PreparePage> createState() => _PreparePageState();
}

class _PreparePageState extends State<PreparePage> {
  File? _file;
  Image? _image;
  GlobalKey _imageKey = GlobalKey();
  bool _loading = false;
  int? width;
  int? height;
  Uint8List? _processedImageBytes;
  bool _success = false;

  List<Coordinate> coords = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                // Handle avatar tap
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
        color: Color(0xb01abc9c),
        child: _file == null ? _buildReadyToUpload() : _buildImagePreview(),
      ),
    );
  }

  Widget _buildReadyToUpload() {
    return Center(
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
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                size: 65.0,
                color: Color(0xffffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _success ? _buildProcessedImageWidget() : _buildImageWidget(),
            SizedBox(height: 10),
            _success ? _buildSuccessButtons() : _buildActionButtons(),
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
    );
  }

  Widget _buildProcessedImageWidget() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height * 0.8),
          // width: MediaQuery.of(context).size.width,
          child: IntrinsicHeight(
            child: Image.memory(_processedImageBytes!, width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
          ),
        ),
      );
    });
  }

  Widget _buildImageWidget() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height * 0.8),
          // width: MediaQuery.of(context).size.width,
          child: IntrinsicHeight(
            child: Stack(
              children: [
                GestureDetector(
                  key: _imageKey,
                  onTapUp: _handleImageTap,
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
                ..._buildPointWidgets(),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildPointWidgets() {
    return coords
        .map((point) => Positioned(
              left: point.x * width! - 5,
              top: point.y * height! - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ))
        .toList();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _resetImage,
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
    );
  }

  Widget _buildSuccessButtons() {
    return Row(
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
          onPressed: _resetImage,
          child: Text('Again'),
        ),
      ],
    );
  }

  void _handleImageTap(TapUpDetails details) {
    setState(() {
      if (coords.length < 3) {
        width = _imageKey.currentContext!.size!.width.toInt();
        height = _imageKey.currentContext!.size!.height.toInt();
        double x = details.localPosition.dx / width!;
        double y = details.localPosition.dy / height!;
        coords.add(Coordinate(x, y));
      }
    });
  }

  void _resetPoints() {
    setState(() {
      coords.clear();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
        _image = Image.file(_file!, width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth);

        // _image!.image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener(
        //   (ImageInfo info, bool _) {
        //     width = info.image.width;
        //     height = info.image.height;
        //   },
        // ));
      });
    }
  }

  void _resetImage() {
    setState(() {
      _file = null;
      _image = null;
      _success = false;
      _loading = false;
      _processedImageBytes = null;
    });
  }

  Future<void> _submitData() async {
    setState(() {
      _loading = true;
    });

    var url = 'http:/127.0.0.1/image/ud';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    var file = _file!;
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', stream, length, filename: 'image.jpg');
    request.files.add(multipartFile);
    request.fields['pos'] = jsonEncode(coords);

    var response = await request.send();

    Map<String, dynamic> respMap = jsonDecode(await response.stream.bytesToString());
    var processResp = ProcessResp.fromJson(respMap);
    if (response.statusCode == 200) {
      if (processResp.processedImage != null && processResp.processedImage!.isNotEmpty) {
        print('process image success');
        setState(() {
          _success = true;
          _processedImageBytes = base64Decode(processResp.processedImage!);
        });
      } else {
        print('process image failed');
        Fluttertoast.showToast(
          msg: processResp.msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print('Failed to submit image');
      Fluttertoast.showToast(
        msg: 'Failed to submit image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      coords.clear();
      _loading = false;
    });
  }

  Future<void> _saveImage() async {
    if (_processedImageBytes != null) {
      final result = await ImageGallerySaver.saveImage(_processedImageBytes!);
      print('Image saved: $result');
    }
  }
}
