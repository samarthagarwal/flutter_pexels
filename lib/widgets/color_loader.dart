import 'dart:math';

import 'package:flutter/material.dart';

import './dot_type.dart';

class ColorLoader extends StatefulWidget {
  final Color dotOneColor;
  final Color dotTwoColor;
  final Color dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  ColorLoader(
      {this.dotOneColor = Colors.redAccent,
      this.dotTwoColor = Colors.green,
      this.dotThreeColor = Colors.blueAccent,
      this.duration = const Duration(milliseconds: 1000),
      this.dotType = DotType.circle,
      this.dotIcon = const Icon(Icons.blur_on)});

  @override
  _ColorLoaderState createState() => _ColorLoaderState();
}

class _ColorLoaderState extends State<ColorLoader> with SingleTickerProviderStateMixin {
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.80, curve: Curves.ease),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.9, curve: Curves.ease),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 1.0, curve: Curves.ease),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      child: Center(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Transform.translate(
              offset: Offset(
                0.0,
                -30 * (animation_1.value <= 0.50 ? animation_1.value : 1.0 - animation_1.value),
              ),
              child: new Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Image.asset(
                  "images/pexels_logo.png",
                  width: 20.0,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(
                0.0,
                -30 * (animation_2.value <= 0.50 ? animation_2.value : 1.0 - animation_2.value),
              ),
              child: new Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Image.asset(
                  "images/pexels_logo.png",
                  width: 20.0,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(
                0.0,
                -30 * (animation_3.value <= 0.50 ? animation_3.value : 1.0 - animation_3.value),
              ),
              child: new Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Image.asset(
                  "images/pexels_logo.png",
                  width: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;
  final DotType type;
  final Icon icon;

  Dot({this.radius, this.color, this.type, this.icon});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: type == DotType.icon
          ? Icon(
              icon.icon,
              color: color,
              size: 1.3 * radius,
            )
          : new Transform.rotate(
              angle: type == DotType.diamond ? pi / 4 : 0.0,
              child: Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(color: color, shape: type == DotType.circle ? BoxShape.circle : BoxShape.rectangle),
              ),
            ),
    );
  }
}
