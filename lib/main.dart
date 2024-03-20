import 'package:flutter/material.dart';
import 'package:qnc_app/nbpuzzle/nbpuzzle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final title = 'Number Blocks Puzzle';
    return NbPuzzleApp();
  }
}

