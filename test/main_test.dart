import 'package:flutter_test/flutter_test.dart';
import 'unit/controllers/auth_controller_test.dart' as auth_test;
import 'unit/controllers/manual_voice_page_test.dart' as manual_voice_page_test;

void main() {
  group("All Tests", () {
    auth_test.main();
    manual_voice_page_test.main();
  });
}
