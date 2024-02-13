import 'package:flutter/material.dart';

void showCustomToast(BuildContext context, String msg, {int timeout = 2}) {
    var overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              msg,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay after 2 seconds
    Future.delayed(Duration(seconds: timeout)).then((_) => overlayEntry.remove());
  }