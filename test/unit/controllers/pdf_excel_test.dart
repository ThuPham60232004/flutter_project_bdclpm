import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_project_bdclpm/features/expense/controllers/pdf_excel_controller.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late PdfExcelController controller;

  setUp(() {
    mockHttpClient = MockClient();
    controller = PdfExcelController();
  });

  group('fetchCategories', () {
    test('API phản hồi thành công (statusCode == 200)', () async {
      final mockResponse = jsonEncode([
        {'_id': '678cf0dfe729fb9da673724c', 'name': 'Thực phẩm', 'icon': 'food'},
        {'_id': '678cf115e729fb9da673724e', 'name': 'Điện tử', 'icon': 'devices'},
        {'_id': '678cf11ce729fb9da6737250', 'name': 'Dịch vụ', 'icon': 'service'},
        {'_id': '678cf122e729fb9da6737252', 'name': 'Thời trang', 'icon': 'style'},
        {'_id': '678cf128e729fb9da6737254', 'name': 'Vận chuyển', 'icon': 'local_shipping'},
        {'_id': '678cf12ee729fb9da6737256', 'name': 'Khác', 'icon': 'category'}
      ]);

      when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response(mockResponse, 200));

      await controller.fetchCategories();

      final result = controller.categories.length == 6;
      print('So sánh số lượng categories: $result');
      expect(result, true);
    });

    test('API trả về lỗi (statusCode != 200)', () async {
      when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response('Error', 400));

      try {
        await controller.fetchCategories();
        fail('Expected an exception but none was thrown');
      } catch (e) {
        final result = controller.isLoadingCategories == false;
        print('So sánh trạng thái isLoadingCategories: $result');
        expect(result, true);
      }
    });

    test('Có lỗi khi gửi yêu cầu (catch (e))', () async {
      when(mockHttpClient.get(any)).thenThrow(Exception('Network Error'));

      try {
        await controller.fetchCategories();
        fail('Dự kiến có ngoại lệ nhưng không có');
      } catch (e) {
        final result = controller.isLoadingCategories == false;
        print('So sánh trạng thái isLoadingCategories khi có lỗi mạng: $result');
        expect(result, true);
      }
    });

  test('Phản hồi API chứa dữ liệu JSON hợp lệ', () async {
    final mockResponse = jsonEncode([
      {'_id': '678cf0dfe729fb9da673724c', 'name': 'Thực phẩm', 'icon': 'food'},
        {'_id': '678cf115e729fb9da673724e', 'name': 'Điện tử', 'icon': 'devices'},
        {'_id': '678cf11ce729fb9da6737250', 'name': 'Dịch vụ', 'icon': 'service'},
        {'_id': '678cf122e729fb9da6737252', 'name': 'Thời trang', 'icon': 'style'},
        {'_id': '678cf128e729fb9da6737254', 'name': 'Vận chuyển', 'icon': 'local_shipping'},
        {'_id': '678cf12ee729fb9da6737256', 'name': 'Khác', 'icon': 'category'}
    ]);

    when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response(mockResponse, 200));

    await controller.fetchCategories();

    print('Dữ liệu categories nhận được: ${controller.categories}');

    final countResult = controller.categories.length == 6;
    final nameResult = controller.categories.isNotEmpty && controller.categories[0]['name'] == 'Thực phẩm';

    print('So sánh số lượng categories: $countResult');
    print('So sánh tên category đầu tiên: $nameResult');

    expect(countResult, true);
    expect(nameResult, true);
  });

    test('isLoadingCategories thay đổi trong quá trình tải dữ liệu', () async {
      final mockResponse = jsonEncode([{"name": "Travel"}]);
      when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response(mockResponse, 200));

      final future = controller.fetchCategories();

      print('So sánh trạng thái isLoadingCategories trước khi tải xong: ${controller.isLoadingCategories == true}');
      expect(controller.isLoadingCategories, true);

      await future;

      final result = controller.isLoadingCategories == false;
      print('So sánh trạng thái isLoadingCategories sau khi tải xong: $result');
      expect(result, true);
    });
  });

  group('updateDescription', () {
    setUp(() {
      controller.categories = [
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
          'description': '',
          'createdAt': '2025-01-19T12:33:25.514Z',
          'updatedAt': '2025-01-20T09:27:22.017Z',
          '__v': 0,
          'icon': 'devices'
        },
        {
          '_id': '678cf11ce729fb9da6737250',
          'name': 'Dịch vụ',
          'description': '',
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
      controller.updateDescription("Thực phẩm");
      final result = controller.descriptionController.text ==
          "Các mặt hàng liên quan đến thực phẩm";
      print("Test categoryName tồn tại: $result");
      expect(result, true);
    });

    test('categoryName không tồn tại', () {
      controller.updateDescription("Không tồn tại");
      final result = controller.descriptionController.text == '';
      print("Test categoryName không tồn tại: $result");
      expect(result, true);
    });

    test('category không rỗng và có khóa description', () {
      controller.updateDescription("Vận chuyển");
      final result = controller.descriptionController.text ==
          "Dịch vụ vận chuyển và logistics";
      print("Test category không rỗng và có khóa description: $result");
      expect(result, true);
    });

    test('category rỗng hoặc không có description', () {
      controller.updateDescription("Dịch vụ");
      final result = controller.descriptionController.text == '';
      print("Test category rỗng hoặc không có description: $result");
      expect(result, true);
    });

    test('description tồn tại và có giá trị', () {
      controller.updateDescription("Thời trang");
      final result = controller.descriptionController.text ==
          "Quần áo và phụ kiện thời trang";
      print("Test description tồn tại và có giá trị: $result");
      expect(result, true);
    });

    test('description không tồn tại hoặc null', () {
      controller.updateDescription("Điện tử");
      final result = controller.descriptionController.text == '';
      print("Test description không tồn tại hoặc null: $result");
      expect(result, true);
    });
  });
}
