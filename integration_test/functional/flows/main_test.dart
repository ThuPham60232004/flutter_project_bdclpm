import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_bdclpm/features/auth/controllers/auth_controller.dart';
import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/home/pages/home_page.dart';
import 'package:flutter_project_bdclpm/features/type/presentation/type_page.dart';
import 'dart:io';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:flutter_project_bdclpm/features/type/presentation/type_page.dart';
import 'package:flutter_project_bdclpm/features/type/controllers/type_page_controller.dart';
import 'package:flutter_project_bdclpm/core/routes/route_names.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';
import 'package:provider/provider.dart';
import '../../../test/mocks/mocks.mocks.dart';
void setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> main() async {
  setupFirebaseMocks();
  await Firebase.initializeApp();

  late AuthController authController;
  late FirebaseAuth firebaseAuth;
  late GoogleSignIn googleSignIn;
  late http.Client httpClient;
  late SharedPreferences prefs;
  late MockCloudApi mockCloudApi;
  setUp(() async {
    HttpOverrides.global = null;
    firebaseAuth = FirebaseAuth.instance;
    googleSignIn = GoogleSignIn();
    httpClient = http.Client();
    mockCloudApi = MockCloudApi();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    authController = AuthController(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      httpClient: httpClient,
    );
  });

  tearDown(() async {
    try {
      await authController.signOut();
      await prefs.clear();
    } catch (e) {
      print('Lỗi khi dọn dẹp: $e');
    }
  });
    Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<CloudApi>.value(value: mockCloudApi),
      ],
      child: MaterialApp(
        home: ScanPage(),
      ),
    );
  }
  group('AuthController Functional Tests với dữ liệu thật', () {
    testWidgets(
      'LoginPage hiển thị và chức năng đăng nhập',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LoginPage(authController: authController),
            routes: {
            RouteNames.type: (context) => TypePage(),
            '/scan': (context) => ScanPage(), 
          },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Đăng nhập với Google'), findsOneWidget);
        await tester.tap(find.byKey(Key('google_sign_in_button')));
        await tester.pumpAndSettle(Duration(seconds: 15));
        expect(find.byType(HomePage), findsOneWidget);
        await tester.pumpAndSettle();
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Thêm chi tiêu'));
        await tester.pumpAndSettle();
        expect(find.byType(TypePage), findsOneWidget);
        expect(find.text('Chọn kiểu nhập'), findsOneWidget);
        expect(find.text('Thêm chi tiêu'), findsOneWidget);
        expect(find.text('Bạn muốn nhập chi tiêu như thế nào'), findsOneWidget);
        expect(find.text('Nhập thủ công, giọng nói'), findsOneWidget);
        expect(find.text('Quét hóa đơn'), findsOneWidget);
        expect(find.text('Quét pdf/excel'), findsOneWidget);
        expect(find.byType(Radio<String>), findsNWidgets(3));
        await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Radio<String> && widget.value == TypePageController.scan,
        ));
        await tester.pumpAndSettle();
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose from gallery'));
        await tester.pumpAndSettle();
        await tester.pump(Duration(seconds: 8));
        expect(find.byType(Image), findsOneWidget);
        await tester.pumpAndSettle();
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Upload to Cloud'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Upload to Cloud'));
        await tester.pump();
        await tester.pumpAndSettle(Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Image uploaded successfully!'), findsOneWidget);
        await tester.pump(Duration(seconds: 25));
        await tester.ensureVisible(find.text('Extract Text'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Extract Text'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Thêm chi tiêu'), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.text('Bạn muốn nhập chi tiêu như thế nào?'), findsOneWidget);
        expect(find.text('Nhập thủ công'), findsOneWidget);
        expect(find.text('Quét hóa đơn'), findsOneWidget);
        expect(find.text('Quét pdf/excel'), findsOneWidget);
        expect(find.text('Nhận dạng giọng nói'), findsOneWidget);
        expect(find.text('Tên cửa hàng'), findsOneWidget);
        expect(find.text('Số tiền'), findsOneWidget);
        expect(find.text('Ngày'), findsOneWidget);
        expect(find.text('Mô tả'), findsOneWidget);
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(find.text('Danh mục'), findsOneWidget);
        expect(find.text('Loại tiền tệ'), findsOneWidget);
        expect(find.text('Lưu chi tiêu'), findsOneWidget);
        await tester.tap(find.text('Lưu chi tiêu'));
        await tester.pumpAndSettle();
      },
    );
  });
}
