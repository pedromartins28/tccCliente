import 'package:cliente/util/route_generator.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:flutter/material.dart';
import 'package:cliente/ui/theme.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coronapp',
      //Theme was built in ui/theme.dart
      theme: buildTheme(),
      //Remove scroll glow
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      //Remove debug banner
      debugShowCheckedModeBanner: false,
      //Define app routes
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

void main() {
  StateWidget stateWidget = StateWidget(
    child: MyApp(),
  );
  runApp(stateWidget);
}
