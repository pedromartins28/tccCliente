import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  FadeRoute({this.page, this.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          settings: settings,
        );
}
