import 'package:flutter/material.dart';

class FadingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  FadingText(this.text, {this.style}) : assert(text != null);

  @override
  _FadingTextState createState() => _FadingTextState();
}

class _FadingTextState extends State<FadingText> with TickerProviderStateMixin {
  final _characters = <MapEntry<String, Animation>>[];
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    var start = 0.2;
    final duration = 0.6 / widget.text.length;
    widget.text.runes.forEach((int rune) {
      final character = String.fromCharCode(rune);
      final animation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          curve: Interval(start, start + duration, curve: Curves.easeInOut),
          parent: _controller,
        ),
      );
      _characters.add(MapEntry(character, animation));
      start += duration;
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _characters
          .map(
            (entry) => FadeTransition(
          opacity: entry.value,
          child: Text(entry.key, style: widget.style),
        ),
      )
          .toList(),
    );
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class JumpingText extends StatelessWidget {
  final Offset begin = Offset(0.0, 0.0);
  final TextStyle style;
  final String text;
  final Offset end;

  JumpingText(this.text, {this.end = const Offset(0.0, -0.5), this.style});

  @override
  Widget build(BuildContext context) {
    return RequestSlideTransition(
      end: end,
      children: text.runes
          .map(
            (rune) => Text(String.fromCharCode(rune), style: style),
      )
          .toList(),
    );
  }
}

class ScalingText extends StatelessWidget {
  final double begin = 1.0;
  final TextStyle style;
  final String text;
  final double end;

  ScalingText(this.text, {this.end = 2.0, this.style});

  @override
  Widget build(BuildContext context) {
    return RequestScaleTransition(
      end: end,
      children: text.runes
          .map(
            (rune) => Text(String.fromCharCode(rune), style: style),
      )
          .toList(),
    );
  }
}

class RequestSlideTransition extends StatefulWidget {
  final Offset begin = Offset.zero;
  final List<Widget> children;
  final bool repeat;
  final Offset end;

  RequestSlideTransition({
    @required this.children,
    this.end = const Offset(0.0, -1.0),
    this.repeat = true,
  }) : assert(children != null);

  @override
  _RequestSlideTransitionState createState() =>
      _RequestSlideTransitionState();
}

class _RequestSlideTransitionState extends State<RequestSlideTransition>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<_WidgetAnimations<Offset>> _widgets = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (widget.children.length * 0.25).round()),
    );

    _widgets = _WidgetAnimations.createList<Offset>(
      widgets: widget.children,
      controller: _controller,
      forwardCurve: Curves.ease,
      reverseCurve: Curves.ease,
      begin: widget.begin,
      end: widget.end,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.end;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _widgets.map(
            (widgetAnimation) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return FractionalTranslation(
                translation: widgetAnimation.forward.value.distanceSquared >=
                    end.distanceSquared
                    ? widgetAnimation.reverse.value
                    : widgetAnimation.forward.value,
                child: widgetAnimation.widget,
              );
            },
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class RequestScaleTransition extends StatefulWidget {
  final List<Widget> children;
  final double begin = 1.0;
  final bool repeat;
  final double end;

  RequestScaleTransition({
    @required this.children,
    this.end = 2.0,
    this.repeat = true,
  }) : assert(children != null);

  @override
  _RequestScaleTransitionState createState() =>
      _RequestScaleTransitionState();
}

class _RequestScaleTransitionState extends State<RequestScaleTransition>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<_WidgetAnimations<double>> _widgets = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (widget.children.length * 0.25).round()),
    );

    _widgets = _WidgetAnimations.createList<double>(
      widgets: widget.children,
      controller: _controller,
      forwardCurve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
      begin: widget.begin,
      end: widget.end,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.end;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _widgets.map(
            (widgetAnimation) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: widgetAnimation.forward.value >= end
                    ? widgetAnimation.reverse.value
                    : widgetAnimation.forward.value,
                child: widgetAnimation.widget,
              );
            },
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WidgetAnimations<T> {
  final Animation<T> forward;
  final Animation<T> reverse;
  final Widget widget;

  _WidgetAnimations({this.widget, this.forward, this.reverse});

  static List<_WidgetAnimations<S>> createList<S>({
    @required List<Widget> widgets,
    @required AnimationController controller,
    Cubic forwardCurve = Curves.ease,
    Cubic reverseCurve = Curves.ease,
    S begin,
    S end,
  }) {
    final animations = <_WidgetAnimations<S>>[];

    var start = 0.0;
    final duration = 1.0 / (widgets.length * 2);
    widgets.forEach((childWidget) {
      final animation = Tween<S>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          curve: Interval(start, start + duration, curve: Curves.ease),
          parent: controller,
        ),
      );

      final revAnimation = Tween<S>(
        begin: end,
        end: begin,
      ).animate(
        CurvedAnimation(
          curve: Interval(start + duration, start + duration * 2,
              curve: Curves.ease),
          parent: controller,
        ),
      );

      animations.add(_WidgetAnimations(
        widget: childWidget,
        forward: animation,
        reverse: revAnimation,
      ));

      start += duration;
    });

    return animations;
  }
}