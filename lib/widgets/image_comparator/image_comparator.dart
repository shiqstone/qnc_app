import 'dart:async';

import 'package:flutter/material.dart';

import 'slider_handler.dart';

class ImageComparator extends StatefulWidget {
  final Image? original;
  final Image? comparison;

  ImageComparator({this.original, this.comparison});

  @override
  _ImageComparatorState createState() => _ImageComparatorState();
}

class _ImageComparatorState extends State<ImageComparator> {
  double _position = 0.5; // Middle of the screen

  late Image original;
  late Image comparison;

  late double _screenWidth;
  double? _imageHeight;

  @override
  void initState() {
    super.initState();

    if (widget.original != null) {
      original = widget.original!;
    } else {
      original = Image.asset('assets/images/origin_model.png', fit: BoxFit.fitWidth);
    }

    if (widget.comparison != null) {
      comparison = widget.comparison!;
    } else {
      comparison = Image.asset('assets/images/comparison_model.jpg', fit: BoxFit.fitWidth);
    }
    _getImageSize(original);
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _position += details.primaryDelta! / maxWidth;
                _position = _position.clamp(0.0, 1.0);
              });
            },
            child: Stack(
              children: [
                // Bottom image
                Positioned.fill(
                  child: original,
                ),
                // Top image with clip path
                Positioned.fill(
                  child: ClipRect(
                    clipper: ImageClipper(_position, maxWidth),
                    child: comparison,
                  ),
                ),
                // The slider handler
                Align(
                  alignment: Alignment(_position * 2 - 1, 0),
                  child: SliderHandler(position: _position, height: _imageHeight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _getImageSize(Image image) async {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        },
      ),
    );
    final Size imageSize = await completer.future;
    setState(() {
      _imageHeight = imageSize.height / imageSize.width * _screenWidth;
    });
  }
}

class ImageClipper extends CustomClipper<Rect> {
  final double position;
  final double maxWidth;

  ImageClipper(this.position, this.maxWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(maxWidth * position, 0, maxWidth, size.height);
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}
