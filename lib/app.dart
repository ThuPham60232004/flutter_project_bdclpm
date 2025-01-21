import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/core/themes/app_theme.dart';
import 'package:flutter_project_bdclpm/core/routes/app_routes.dart';
import 'package:flutter_project_bdclpm/core/routes/route_names.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: RouteNames.home,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return AppInheritedTheme(
          themeMode: _themeMode,
          toggleTheme: _toggleTheme,
          child: child!,
        );
      },
    );
  }
}

class AppInheritedTheme extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const AppInheritedTheme({
    required Widget child,
    required this.themeMode,
    required this.toggleTheme,
    Key? key,
  }) : super(key: key, child: child);

  static AppInheritedTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppInheritedTheme>();
  }

  @override
  bool updateShouldNotify(covariant AppInheritedTheme oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}
