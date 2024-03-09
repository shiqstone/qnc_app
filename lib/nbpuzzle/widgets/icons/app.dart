import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({required this.size}) : super();

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    return Semantics(
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        child: Material(
          shape: CircleBorder(),
          elevation: 4.0,
          color: Theme.of(context).hintColor,
          child: Center(
            child: Text(
              '42',
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
