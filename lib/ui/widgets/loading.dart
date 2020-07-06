import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  final Widget progressIndicator;
  final bool dismissible;
  final bool inAsyncCall;
  final double opacity;
  final Offset offset;
  final Widget child;
  final Color color;

  LoadingPage({
    this.progressIndicator = const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.black),
    ),
    this.color = Colors.black54,
    @required this.inAsyncCall,
    this.dismissible = false,
    @required this.child,
    this.opacity = 0.7,
    this.offset,
    Key key,
  })  : assert(inAsyncCall != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      if (offset == null) {
        layOutProgressIndicator = Center(
          child: Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
                height: 30.0,
                width: 30.0,
              ),
            ),
          ),
        );
      } else {
        layOutProgressIndicator = Positioned(
          child: progressIndicator,
          left: offset.dx,
          top: offset.dy,
        );
      }
      final modal = [
        Opacity(
          child: ModalBarrier(dismissible: dismissible, color: color),
          opacity: opacity,
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return Stack(
      children: widgetList,
    );
  }
}
