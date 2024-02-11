import 'dart:math';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final Function(int index) changeIndex;
  final Function onClickMenu;
  final List<IconData> tabIconsList;
  final Animation<double> animation;
  final Animation<double> menuAnimation;

  const SideMenu({
    Key? key,
    required this.tabIconsList,
    required this.changeIndex,
    required this.onClickMenu,
    required this.animation,
    required this.menuAnimation,
  }) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final double menuBtnSize = 52.0;
  final double iconSize = 46.0;
  IconData lastTapped = Icons.home;
  final menuHeight = 220.0;

  Widget _buildFlowChildren(int index, IconData icon) {
    return Container(
      alignment: Alignment.center,
      child: RawMaterialButton(
        fillColor: lastTapped == icon ? Colors.amber[700] : Colors.blue[400],
        shape: const CircleBorder(),
        constraints: BoxConstraints.tight(Size(iconSize, iconSize)),
        child: Icon(icon, color: Colors.white),
        onPressed: () => _onClickMenuIcon(index, icon),
      ),
    );
  }

  void _onClickMenuIcon(int index, IconData icon) {
    // filter repeat choosed
    if (lastTapped == icon) return;

    setState(() => lastTapped = icon);

    widget.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3 * 2, //menuHeight,
      alignment: Alignment.centerRight,
      width: MediaQuery.of(context).size.width - 60, //double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// popup menu
          Positioned.fill(
            child: Flow(
              clipBehavior: Clip.none,
              delegate: FlowAnimatedCircle(widget.animation),
              children: widget.tabIconsList
                  .asMap()
                  .keys
                  .map((index) => _buildFlowChildren(index, widget.tabIconsList[index]))
                  .toList(),
            ),
          ),

          /// menu button
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: RawMaterialButton(
                fillColor: Colors.blue[600],
                shape: const CircleBorder(),
                constraints: BoxConstraints.tight(Size(menuBtnSize, menuBtnSize)),
                child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: widget.menuAnimation,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  widget.onClickMenu();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlowAnimatedCircle extends FlowDelegate {
  final Animation<double> animation;

  final double iconSize = 48.0;
  final paddingHorizontal = 8.0;
  final paddingVertical = 8.0;

  FlowAnimatedCircle(this.animation) : super(repaint: animation);

  @override
  void paintChildren(FlowPaintingContext context) {
    // debugPrint('longer   context.size >>> ${context.size}');

    final progress = animation.value;
    if (progress == 0) return;

    var radius = context.size.width / 4; //context.size.width / 2 - iconSize;

    double x = 0;
    double y = 0;


    var swidth = context.size.width;
    var roffset = (swidth - iconSize) / 3 * 2 - iconSize - paddingHorizontal;

    var degrees = [100, 40, 0, -40, -100];
    for (int i = 0; i < 5; i++) {
      var degree = degrees[i];
      var rad = pi * degree / 180;

      var offsetX = radius - (radius * cos(rad)) - iconSize;
      x = progress * (offsetX - roffset / 2) + roffset;
      y = progress * (radius * 1.5 * -sin(rad));


      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          x,
          y,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(FlowAnimatedCircle oldDelegate) => false;
}
