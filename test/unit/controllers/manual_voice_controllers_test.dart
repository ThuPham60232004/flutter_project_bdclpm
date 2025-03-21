import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../../mocks/mocks.mocks.dart';
import 'dart:convert';
import '../../test_config.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/manual_voice_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  late ExpenseManager expenseManager;
  late MockClient mockClient;
  late SharedPreferences sharedPreferences;
  late MockPermission mockPermission;
  late MockSpeechToText mockSpeechToText;
  late MockScaffoldMessengerState mockScaffoldMessenger;
  late TextEditingController controller;
  setUp(() async {
    setupTestEnvironment();
    mockClient = MockClient();
    mockPermission = MockPermission();
    mockSpeechToText = MockSpeechToText();
    mockScaffoldMessenger = MockScaffoldMessengerState();
    controller = TextEditingController();
    SharedPreferences.setMockInitialValues({'userId': 'mockUserId'});
    sharedPreferences = await SharedPreferences.getInstance();
    expenseManager = ExpenseManager(
      (message) => debugPrint('Snackbar: $message'),
      Future.value(sharedPreferences),
      httpClient: mockClient,
    );
  });
  group('Manual Voice Controller - Fetch Categories', () {
    test('API phản hồi thành công (statusCode == 200)', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              '_id': '678cf0dfe729fb9da673724c',
              'name': 'Thực phẩm',
              'description': 'Các mặt hàng liên quan đến thực phẩm',
              'createdAt': '2025-01-19T12:32:31.702Z',
              'updatedAt': '2025-01-20T09:26:26.883Z',
              '__v': 0,
              'icon': 'food'
            },
            {
              '_id': '678cf115e729fb9da673724e',
              'name': 'Điện tử',
              'description': 'Thiết bị và dụng cụ điện tử',
              'createdAt': '2025-01-19T12:33:25.514Z',
              'updatedAt': '2025-01-20T09:27:22.017Z',
              '__v': 0,
              'icon': 'devices'
            },
            {
              '_id': '678cf11ce729fb9da6737250',
              'name': 'Dịch vụ',
              'description': 'Các dịch vụ và tiện ích',
              'createdAt': '2025-01-19T12:33:32.175Z',
              'updatedAt': '2025-01-20T09:27:15.636Z',
              '__v': 0,
              'icon': 'service'
            },
            {
              '_id': '678cf122e729fb9da6737252',
              'name': 'Thời trang',
              'description': 'Quần áo và phụ kiện thời trang',
              'createdAt': '2025-01-19T12:33:38.130Z',
              'updatedAt': '2025-01-20T09:27:03.000Z',
              '__v': 0,
              'icon': 'style'
            },
            {
              '_id': '678cf128e729fb9da6737254',
              'name': 'Vận chuyển',
              'description': 'Dịch vụ vận chuyển và logistics',
              'createdAt': '2025-01-19T12:33:44.922Z',
              'updatedAt': '2025-01-20T09:27:39.335Z',
              '__v': 0,
              'icon': 'local_shipping'
            },
            {
              '_id': '678cf12ee729fb9da6737256',
              'name': 'Khác',
              'description': 'Các mặt hàng khác',
              'createdAt': '2025-01-19T12:33:50.809Z',
              'updatedAt': '2025-01-20T09:27:53.226Z',
              '__v': 0,
              'icon': 'category'
            }
          ]),
          200,
        ),
      );

      await expenseManager.fetchCategories();

      expect(expenseManager.categories, isA<List>());
      expect(expenseManager.categories.length, 6);
      expect(expenseManager.categories.first['name'], 'Thực phẩm');
      expect(expenseManager.isLoadingCategories, false);
    });
    // test('API trả về lỗi (statusCode != 200)', () async {
    //   when(mockClient.get(any))
    //       .thenAnswer((_) async => http.Response('Error', 500));

    //   expect(() async => await expenseManager.fetchCategories(),
    //       throwsA(isA<Exception>()));
    // });

    // test('Có lỗi khi gửi yêu cầu (catch (e))', () async {
    //   when(mockClient.get(any)).thenThrow(Exception('Network Error'));

    //   await expenseManager.fetchCategories();

    //   expect(expenseManager.categories, isEmpty);
    //   expect(expenseManager.isLoadingCategories, false);
    // });

    test('API phản hồi dữ liệu JSON hợp lệ', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              '_id': '678cf0dfe729fb9da673724c',
              'name': 'Thực phẩm',
              'description': 'Các mặt hàng liên quan đến thực phẩm',
              'createdAt': '2025-01-19T12:32:31.702Z',
              'updatedAt': '2025-01-20T09:26:26.883Z',
              '__v': 0,
              'icon': 'food'
            },
            {
              '_id': '678cf115e729fb9da673724e',
              'name': 'Điện tử',
              'description': 'Thiết bị và dụng cụ điện tử',
              'createdAt': '2025-01-19T12:33:25.514Z',
              'updatedAt': '2025-01-20T09:27:22.017Z',
              '__v': 0,
              'icon': 'devices'
            },
            {
              '_id': '678cf11ce729fb9da6737250',
              'name': 'Dịch vụ',
              'description': 'Các dịch vụ và tiện ích',
              'createdAt': '2025-01-19T12:33:32.175Z',
              'updatedAt': '2025-01-20T09:27:15.636Z',
              '__v': 0,
              'icon': 'service'
            },
            {
              '_id': '678cf122e729fb9da6737252',
              'name': 'Thời trang',
              'description': 'Quần áo và phụ kiện thời trang',
              'createdAt': '2025-01-19T12:33:38.130Z',
              'updatedAt': '2025-01-20T09:27:03.000Z',
              '__v': 0,
              'icon': 'style'
            },
            {
              '_id': '678cf128e729fb9da6737254',
              'name': 'Vận chuyển',
              'description': 'Dịch vụ vận chuyển và logistics',
              'createdAt': '2025-01-19T12:33:44.922Z',
              'updatedAt': '2025-01-20T09:27:39.335Z',
              '__v': 0,
              'icon': 'local_shipping'
            },
            {
              '_id': '678cf12ee729fb9da6737256',
              'name': 'Khác',
              'description': 'Các mặt hàng khác',
              'createdAt': '2025-01-19T12:33:50.809Z',
              'updatedAt': '2025-01-20T09:27:53.226Z',
              '__v': 0,
              'icon': 'category'
            }
          ]),
          200,
        ),
      );

      await expenseManager.fetchCategories();

      expect(expenseManager.categories, isA<List>());
      expect(
          expenseManager.categories.first, containsPair('name', 'Thực phẩm'));
      expect(expenseManager.categories.first,
          containsPair('description', 'Các mặt hàng liên quan đến thực phẩm'));
    });

    test('isLoadingCategories thay đổi trong quá trình tải dữ liệu', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(
            jsonEncode([
              {"name": "Giáo dục"}
            ]),
            200),
      );
      expect(expenseManager.isLoadingCategories, true);

      await expenseManager.fetchCategories();
      expect(expenseManager.isLoadingCategories, false);
    });
  });
  group('Manual Voice Controller - Update Description', () {
    setUp(() async {
      expenseManager.categories = [
        {
          '_id': '678cf0dfe729fb9da673724c',
          'name': 'Thực phẩm',
          'description': 'Các mặt hàng liên quan đến thực phẩm',
          'createdAt': '2025-01-19T12:32:31.702Z',
          'updatedAt': '2025-01-20T09:26:26.883Z',
          '__v': 0,
          'icon': 'food'
        },
        {
          '_id': '678cf115e729fb9da673724e',
          'name': 'Điện tử',
          'description': 'Thiết bị và dụng cụ điện tử',
          'createdAt': '2025-01-19T12:33:25.514Z',
          'updatedAt': '2025-01-20T09:27:22.017Z',
          '__v': 0,
          'icon': 'devices'
        },
        {
          '_id': '678cf11ce729fb9da6737250',
          'name': 'Dịch vụ',
          'description': 'Các dịch vụ và tiện ích',
          'createdAt': '2025-01-19T12:33:32.175Z',
          'updatedAt': '2025-01-20T09:27:15.636Z',
          '__v': 0,
          'icon': 'service'
        },
        {
          '_id': '678cf122e729fb9da6737252',
          'name': 'Thời trang',
          'description': 'Quần áo và phụ kiện thời trang',
          'createdAt': '2025-01-19T12:33:38.130Z',
          'updatedAt': '2025-01-20T09:27:03.000Z',
          '__v': 0,
          'icon': 'style'
        },
        {
          '_id': '678cf128e729fb9da6737254',
          'name': 'Vận chuyển',
          'description': 'Dịch vụ vận chuyển và logistics',
          'createdAt': '2025-01-19T12:33:44.922Z',
          'updatedAt': '2025-01-20T09:27:39.335Z',
          '__v': 0,
          'icon': 'local_shipping'
        },
        {
          '_id': '678cf12ee729fb9da6737256',
          'name': 'Khác',
          'description': 'Các mặt hàng khác',
          'createdAt': '2025-01-19T12:33:50.809Z',
          'updatedAt': '2025-01-20T09:27:53.226Z',
          '__v': 0,
          'icon': 'category'
        }
      ];
    });

    test('categoryName tồn tại trong categories', () {
      expenseManager.updateDescription('Thực phẩm');
      expect(expenseManager.descriptionController.text,
          'Các mặt hàng liên quan đến thực phẩm');
    });

    test('categoryName không tồn tại', () {
      expenseManager.updateDescription('Du lịch');
      expect(expenseManager.descriptionController.text, '');
    });

    test('category không rỗng và có khóa description', () {
      expenseManager.updateDescription('Điện tử');
      expect(expenseManager.descriptionController.text,
          'Thiết bị và dụng cụ điện tử');
    });

    test('category rỗng hoặc không có description', () {
      expenseManager.categories = [
        {'name': 'Thể thao'}
      ];
      expenseManager.updateDescription('Thể thao');
      expect(expenseManager.descriptionController.text, '');
    });

    test('description tồn tại và có giá trị', () {
      expenseManager.updateDescription('Thực phẩm');
      expect(expenseManager.descriptionController.text.isNotEmpty, true);
    });

    test('description không tồn tại hoặc null', () {
      expenseManager.categories = [
        {'name': 'Âm nhạc', 'description': null}
      ];
      expenseManager.updateDescription('Âm nhạc');
      expect(expenseManager.descriptionController.text, '');
    });
  });
  // group('Microphone Permission', () {
  //   test('Quyền đã được cấp (status.isGranted)', () async {
  //     when(mockPermission.status).thenAnswer((_) async => PermissionStatus.granted);

  //     final status = await mockPermission.status;
  //     expect(status.isGranted, true);
  //   });

  //   test('Quyền chưa được cấp (status.isDenied)', () async {
  //     when(mockPermission.status).thenAnswer((_) async => PermissionStatus.denied);

  //     final status = await mockPermission.status;
  //     expect(status.isDenied, true);
  //   });

  //   test('Quyền chưa được cấp (status.isPermanentlyDenied)', () async {
  //     when(mockPermission.status).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

  //     final status = await mockPermission.status;
  //     expect(status.isPermanentlyDenied, true);
  //   });

  //   test('Người dùng cấp quyền sau khi request', () async {
  //     when(mockPermission.request()).thenAnswer((_) async => PermissionStatus.granted);

  //     final status = await mockPermission.request();
  //     expect(status.isGranted, true);
  //   });

  //   test('Người dùng từ chối quyền sau khi request', () async {
  //     when(mockPermission.request()).thenAnswer((_) async => PermissionStatus.denied);

  //     final status = await mockPermission.request();
  //     expect(status.isDenied, true);
  //   });

  //   test('Hiển thị Snackbar khi quyền chưa được cấp', () async {
  //     when(mockPermission.status).thenAnswer((_) async => PermissionStatus.denied);
  //     when(mockPermission.request()).thenAnswer((_) async => PermissionStatus.denied);

  //     bool isSnackbarShown = false;
  //     void _showSnackBar(String message) {
  //       isSnackbarShown = true;
  //     }

  //     Future<void> checkMicrophonePermission() async {
  //       var status = await mockPermission.status;
  //       if (status.isDenied || status.isPermanentlyDenied) {
  //         status = await mockPermission.request();
  //       }
  //       if (!status.isGranted) {
  //         _showSnackBar('Quyền micro chưa được cấp! Vui lòng cấp quyền trong cài đặt.');
  //       }
  //     }

  //     await checkMicrophonePermission();

  //     expect(isSnackbarShown, true);
  //   });
  // });
  group('startListening', () {
    // test('checkMicrophonePermission quyền micro đã được cấp', () async {
    //   when(mockPermission.status)
    //       .thenAnswer((_) async => PermissionStatus.granted);
    //   await expenseManager.checkMicrophonePermission();
    //   verify(mockPermission.status).called(1);
    // });

    // test('checkMicrophonePermissionquyền bị từ chối', () async {
    //   when(mockPermission.status)
    //       .thenAnswer((_) async => PermissionStatus.denied);
    //   await expenseManager.checkMicrophonePermission();
    //   verify(mockPermission.status).called(1);
    // });

    test('_speech.initialize khởi tạo thành công', () async {
      when(mockSpeechToText.initialize()).thenAnswer((_) async => true);
      expect(await mockSpeechToText.initialize(), isTrue);
    });

    test('_speech.initialize khởi tạo thất bại', () async {
      when(mockSpeechToText.initialize()).thenAnswer((_) async => false);
      expect(await mockSpeechToText.initialize(), isFalse);
    });
    // test("field == 'storeName'", () {
    //   expenseManager.startListening(controller, 'storeName');
    //   expect(expenseManager.isListeningForStoreName, isTrue);
    // });

    // test("field == 'amount'", () {
    //   expenseManager.startListening(controller, 'amount');
    //   expect(expenseManager.isListeningForAmount, isTrue);
    // });

    // test("field == 'description'", () {
    //   expenseManager.startListening(controller, 'description');
    //   expect(expenseManager.isListeningForDescription, isTrue);
    // });

    // test("field == 'date'", () {
    //   expenseManager.startListening(controller, 'date');
    //   expect(expenseManager.isListeningForDate, isTrue);
    // });

    // test('available == false', () async {
    //   when(mockSpeechToText.initialize()).thenAnswer((_) async => false);
    //   await expenseManager.startListening(controller, 'storeName');
    //   verify(mockScaffoldMessenger.showSnackBar(any)).called(1);
    // });
  });
  // group('stopListening', () {
  //   test('stops listening for storeName', () {
  //     when(mockSpeechToText.stop()).thenAnswer((_) async {});
      
  //     expenseManager.stopListening('storeName');

  //     expect(expenseManager.isListeningForStoreName, false);
  //     verify(mockSpeechToText.stop()).called(1);
  //   });


  //  test('stops listening for amount', () {
  //     when(mockSpeechToText.stop()).thenAnswer((_) async {});
      
  //     expenseManager.stopListening('amount');

  //     expect(expenseManager.isListeningForAmount, false);
  //     verify(mockSpeechToText.stop()).called(1);
  //   });

  // test('stops listening for description', () {
  //   when(mockSpeechToText.stop()).thenAnswer((_) async {});

  //   expenseManager.stopListening('description');

  //   expect(expenseManager.isListeningForDescription, false);
  //   verify(mockSpeechToText.stop()).called(1);
  // });


  //   // test('stops listening for date', () {
  //   //   expenseManager._isListeningForDate = true;
  //   //   when(mockSpeechToText.stop()).thenAnswer((_) async {});
      
  //   //   expenseManager.stopListening('date');

  //   //   expect(expenseManager._isListeningForDate, false);
  //   //   verify(mockSpeechToText.stop()).called(1);
  //   // });

  //   test('calls _speech.stop() when speech recognition is running', () {
  //     when(mockSpeechToText.isListening).thenReturn(true);
  //     when(mockSpeechToText.stop()).thenAnswer((_) async {});
      
  //     expenseManager.stopListening('storeName');
      
  //     verify(mockSpeechToText.stop()).called(1);
  //   });

  //   test('does not call _speech.stop() when speech recognition is not running', () {
  //     when(mockSpeechToText.isListening).thenReturn(false);
      
  //     expenseManager.stopListening('storeName');
      
  //     verifyNever(mockSpeechToText.stop());
  //   });
  // });
  group('Manual Voice Controller', () {
    test('Kiểm tra tải danh mục thành công', () async {
      when(mockClient.get(
              Uri.parse('https://backend-bdclpm.onrender.com/api/categories')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    '_id': '1',
                    'name': 'Thực phẩm',
                    'description': 'Chi tiêu ăn uống'
                  }
                ]),
                200,
              ));

      await expenseManager.fetchCategories();

      expect(expenseManager.categories.isNotEmpty, true);
      expect(expenseManager.categories.first['name'], 'Thực phẩm');
    });

    test('Kiểm tra lưu chi tiêu thành công', () async {
      expenseManager.storeNameController.text = 'Quán ăn A';
      expenseManager.amountController.text = '100000';
      expenseManager.dateController.text = '01/02/2025';
      expenseManager.setCategory('Ăn uống');
      expenseManager.categories = [
        {'_id': '1', 'name': 'Ăn uống', 'description': 'Chi tiêu ăn uống'}
      ];

      when(mockClient.post(
        Uri.parse('https://backend-bdclpm.onrender.com/api/expenses'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"message":"Success"}', 201));

      await expenseManager.saveExpense();

      expect(expenseManager.storeNameController.text, 'Quán ăn A');
      expect(expenseManager.amountController.text, '100000');
      expect(expenseManager.dateController.text, '01/02/2025');
      expect(expenseManager.category, 'Ăn uống');
    });

    test('Kiểm tra thông báo lỗi khi thiếu dữ liệu', () {
      expenseManager.storeNameController.text = '';
      expenseManager.amountController.text = '';
      expenseManager.dateController.text = '';
      expenseManager.setCategory(null);

      expenseManager.saveExpense();

      expect(expenseManager.storeNameController.text.isEmpty, true);
      expect(expenseManager.amountController.text.isEmpty, true);
      expect(expenseManager.dateController.text.isEmpty, true);
      expect(expenseManager.category, null);
    });
  });
}
