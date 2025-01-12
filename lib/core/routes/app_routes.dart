import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/home/presentation/pages/home_page.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/load/presentation/pages/upload_page.dart';
import 'route_names.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    RouteNames.home: (context) => const HomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.load: (context) =>  UploadPage(),
  };
}
