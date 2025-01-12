import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/home/presentation/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_bdclpm/firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_names.dart';
import 'core/themes/app_theme.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
      ),
      themeMode: ThemeMode.light,
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
      initialRoute: RouteNames.home,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return AppInheritedTheme(
          themeMode: ThemeMode.light,
          toggleTheme: () {},
          child: child!,
        );
      },
    );
  }
}
