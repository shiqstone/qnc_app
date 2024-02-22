import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:qnc_app/appbar.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/login.dart';
import 'package:qnc_app/model/ws_msg.dart';
import 'package:qnc_app/nbpuzzle/nbpuzzle.dart';
import 'package:qnc_app/recharge.dart';
import 'package:qnc_app/utils/log.dart';
import 'package:qnc_app/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:qnc_app/model/coordinate.dart';
import 'package:qnc_app/model/process_resp.dart';

class PrepareQncPage extends StatefulWidget {
  @override
  State<PrepareQncPage> createState() => _PrepareQncPageState();
}

class _PrepareQncPageState extends State<PrepareQncPage> {
  File? _file;
  Image? _image;
  // GlobalKey _imageKey = GlobalKey();
  bool _loading = false;
  int? width;
  int? height;
  Uint8List? _processedImageBytes;
  bool _success = false;
  int? _orderId;
  String? _token;

  late QncAppStateProvider qncProvider;

  late QncAppBar appbar;

  List<Coordinate> coords = [];

  late WebSocketChannel _channel;
  late SharedPreferences sharedPreferences;

  String wsUrl = Constant.wsBaseUrl + '/ws';

  @override
  void initState() {
    super.initState();

    initWsConnect();
  }

  void initWsConnect() {
    getCurToken().then((token) {
      if (token != null && token.isNotEmpty) {
        _token = token;
        _channel = IOWebSocketChannel.connect(
          wsUrl,
        );
        LogUtil.i('[ws]: connected');
        _channel.sink.add(token);

        _channel.stream.listen((event) {
          LogUtil.i('on message');
          onMessage(event);
        }, onDone: () {
          LogUtil.i('connect closed');
          // reconnect();
        }, onError: (e) {
          WebSocketChannelException except = e;
          LogUtil.i('connect error');
          LogUtil.e(except.message);
        });
      } else {
        LogUtil.i('[ws]: not login, cannot connect');
        // Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
      }
    });
  }

  Future<String?> getCurToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('token');
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    qncProvider = Provider.of<QncAppStateProvider>(context);
    return Scaffold(
      appBar: QncAppBar(
        onUpdateToken: updateToken,
      ),
      body: Container(
        color: Color(0xb01abc9c),
        child: _file == null ? _buildReadyToUpload() : _buildImagePreview(),
      ),
    );
  }

  void updateToken(String token) {
    setState(() {
      _token = token;
    });
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
                  // key: _imageKey,
                  onTapUp: (details) => _handleImageTap(details, context),
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
          label: Text('Upload'),
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

  void _handleImageTap(TapUpDetails details, BuildContext context) {
    setState(() {
      if (coords.length < 3) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        width = renderBox.size.width.toInt();
        height = renderBox.size.height.toInt();
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

      coords.clear();
    });
  }

  Future<void> _submitData() async {
    LogUtil.d('cur token $_token');
    if (_token == null || _token!.isEmpty) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
    }

    setState(() {
      _loading = true;
    });

    var url = Constant.httpBaseUrl + '/image/ud/';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    var file = _file!;
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    Map<String, String> headers = <String, String>{'Authorization': 'Bearer ' + _token!};
    request.headers.addAll(headers);
    var multipartFile = http.MultipartFile('file', stream, length, filename: 'image.jpg');
    request.files.add(multipartFile);
    request.fields['pos'] = jsonEncode(coords);

    // var response = await request.send();
    request.send().then((response) async {
      if (response.statusCode == 200) {
        Map<String, dynamic> respMap = jsonDecode(await response.stream.bytesToString());
        var processResp = ProcessResp.fromJson(respMap);
        if (processResp.statusCode == 10003 || processResp.statusCode == 10005) {
          LogUtil.i('no login');

          setState(() {
            coords.clear();
            _loading = false;
          });

          Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
        } else if (processResp.statusCode == 10006) {
          LogUtil.i('balance not enough');

          setState(() {
            coords.clear();
            _loading = false;
          });

          Navigator.push(context, new MaterialPageRoute(builder: (context) => new RechargePage())).then((value) {
            qncProvider.updateBalance(value);
          });
        } else if (processResp.statusCode != 0) {
          LogUtil.e('process image failed');

          showCustomToast(context, processResp.statusMsg ?? 'process image failed');

          setState(() {
            coords.clear();
            _loading = false;
          });
        } else {
          if (processResp.orderId != null) {
            _orderId = processResp.orderId;
          }
        }
      } else {
        LogUtil.e('Failed to submit image');
        showCustomToast(context, 'Connect to server error');

        setState(() {
          coords.clear();
          _loading = false;
        });
      }
    }).catchError((error) {
      LogUtil.e(error);
    });
  }

  Future<void> _saveImage() async {
    if (_processedImageBytes != null) {
      final result = await ImageGallerySaver.saveImage(_processedImageBytes!);
      LogUtil.i('Image saved: $result');
    }
  }

  void onMessage(data) {
    Map<String, dynamic> respMap = jsonDecode(data);
    var wsMsg = WsMsg.fromJson(respMap);
    if (wsMsg.code == 0 && wsMsg.data != null) {
      // process success
      Map<String, dynamic> dataMap = jsonDecode(wsMsg.data!);
      var processResp = ProcessResp.fromJson(dataMap);
      if (processResp.orderId == _orderId &&
          processResp.processedImage != null &&
          processResp.processedImage!.isNotEmpty) {
        setState(() {
          _success = true;
          _processedImageBytes = base64Decode(processResp.processedImage!);

          coords.clear();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });

        showCustomToast(context, processResp.statusMsg ?? 'process image failed');
      }
    } else {
      setState(() {
        _loading = false;
      });

      showCustomToast(context, wsMsg.msg);
    }
  }
}
