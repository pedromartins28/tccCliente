import 'package:cliente/ui/pages/chat2.dart';
import 'package:cliente/ui/pages/picker_info.dart';
import 'package:cliente/ui/pages/show_photo.dart';
import 'package:cliente/ui/pages/sign.dart';
import 'package:cliente/ui/pages/tabs/create_request.dart';
import 'package:cliente/ui/pages/tabs/create_request2.dart';
import 'package:cliente/ui/pages/tabs/new_home.dart';
import 'package:cliente/ui/pages/tabs/request.dart';
import 'package:cliente/ui/pages/tabs/request2.dart';
import 'package:cliente/util/fade_route.dart';
import 'package:cliente/ui/pages/about.dart';
import 'package:cliente/ui/pages/chat.dart';
import 'package:cliente/ui/pages/tabs/home.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/request':
        return MaterialPageRoute(
          settings: RouteSettings(
            name: '/request',
          ),
          builder: (_) => RequestPage(),
        );
      case '/request2':
        return MaterialPageRoute(
          settings: RouteSettings(
            name: '/request2',
          ),
          builder: (_) => RequestPage2(),
        );
      case '/':
        return MaterialPageRoute(
          settings: RouteSettings(
            name: '/',
          ),
          builder: (_) => HomePage(),
        );
      case '/volunt':
        return FadeRoute(
          settings: RouteSettings(
            name: '/volunt',
          ),
          page: CreateRequest(),
        );
      case '/medic':
        return FadeRoute(
          settings: RouteSettings(
            name: '/medic',
          ),
          page: CreateRequest2(),
        );
      case '/signin':
        return FadeRoute(
          settings: RouteSettings(
            name: '/signin',
          ),
          page: SignInPage(),
        );
      case '/chat':
        return FadeRoute(
          settings: RouteSettings(
            name: '/chat',
          ),
          page: ChatPage(),
        );
      case '/chat2':
        return FadeRoute(
          settings: RouteSettings(
            name: '/chat2',
          ),
          page: ChatPage2(),
        );

      case '/picker_info':
        if (args is String)
          return FadeRoute(
            settings: RouteSettings(
              name: '/picker_info',
            ),
            page: PickerInfoPage(args),
          );
        return _errorRoute();
      case '/show_photo':
        if (args is Map)
          return FadeRoute(
            settings: RouteSettings(
              name: '/show_photo',
            ),
            page: ShowPhotoPage(args),
          );
        return _errorRoute();
      case '/about':
        return FadeRoute(
          settings: RouteSettings(
            name: '/about',
          ),
          page: AboutPage(),
        );
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      settings: RouteSettings(
        name: '/error',
      ),
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('NOT FOUND'),
          ),
          body: Center(
            child: Text('ROUTE NOT FOUND'),
          ),
        );
      },
    );
  }
}
