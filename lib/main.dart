import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/home/pages/home_page.dart';
import 'package:flutter_project_bdclpm/firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_names.dart';
import 'core/themes/app_theme.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: ".env.dev");
    debugPrint("✅ .env file loaded successfully!");
  } catch (e) {
    debugPrint("❌ Error loading .env file: $e");
  }

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
        appBarTheme: const AppBarTheme(color: Colors.black),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(color: Colors.black),
      ),
      themeMode: ThemeMode.light,
      initialRoute: RouteNames.login,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return AppInheritedTheme(
          themeMode: ThemeMode.light,
          toggleTheme: () {},
          child: child!,
        );
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.hasData ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}
