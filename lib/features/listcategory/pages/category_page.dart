import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/listcategory/pages/list_category.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://backend-bdclpm.onrender.com/api/categories/'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải danh mục');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Lỗi tải danh mục: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 6,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListCategoryPage(
                            categoryId: category['_id'],
                            categoryName: category['name'],
                          ),
                        ),
                      );
                    },
                    child: CategoryTile(
                      name: category['name'],
                      iconName: category['icon'],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String name;
  final String iconName;

  const CategoryTile({required this.name, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 160, 195, 255),
            const Color.fromARGB(255, 178, 127, 255)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIconFromString(iconName),
            size: 45,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'food':
      return Icons.fastfood;
    case 'devices':
      return Icons.devices;
    case 'service':
      return Icons.design_services;
    case 'local_shipping':
      return Icons.local_shipping;
    case 'style':
      return Icons.style;
    case 'Khác':
      return Icons.help_outline;
    default:
      return Icons.help;
  }
}
