import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryController {
  List<dynamic> categories = [];
  bool isLoading = true;

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://backend-bdclpm.onrender.com/api/categories/'));
      if (response.statusCode == 200) {
        categories = json.decode(response.body);
        isLoading = false;
      } else {
        throw Exception('Không thể tải danh mục');
      }
    } catch (error) {
      isLoading = false;
      print('Lỗi tải danh mục: $error');
    }
  }

  List<dynamic> getCategories() => categories;
  bool getIsLoading() => isLoading;
}
