import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/home/presentation/pages/home_page.dart';
import 'package:flutter_project_bdclpm/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/type/presentation/pages/type_page.dart';
import 'package:flutter_project_bdclpm/features/manual_voice/presentation/pages/manual_voice.dart';
import 'package:flutter_project_bdclpm/features/pdf_excel/presentation/pages/pdf_excel.dart';
import 'package:flutter_project_bdclpm/features/scan/presentation/pages/scan.dart';
import 'package:flutter_project_bdclpm/features/history/pages/history_page.dart';
import 'package:flutter_project_bdclpm/features/history/pages/history_income.dart';
import 'package:flutter_project_bdclpm/features/budget/pages/add_budget.dart';
import 'package:flutter_project_bdclpm/features/listcategory/pages/category_page.dart';
import 'package:flutter_project_bdclpm/features/budget/pages/list_budget.dart';
import 'package:flutter_project_bdclpm/features/listcategory/pages/expenses_category.dart';
import 'package:flutter_project_bdclpm/features/income/presentation/page/income.dart';
import 'package:flutter_project_bdclpm/features/income/echarts/echarts.dart';
import 'route_names.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    RouteNames.home: (context) => const HomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.scan: (context) => ScanPage(),
    RouteNames.type: (context) => TypePage(),
    RouteNames.manualvoice: (context) => ManualVoicePage(),
    RouteNames.pdfexcel: (context) => PdfExcelPage(),
    RouteNames.history: (context) => HistoryPage(),
    RouteNames.addbudget: (context) => CreateBudgetScreen(),
    RouteNames.categories: (context) => CategoryPage(),
    RouteNames.listbudgets: (context) => BudgetListPage(),
    RouteNames.categorywise: (context) => CategoryWiseExpensesPage(),
    RouteNames.income: (context) => IncomeScreen(),
    RouteNames.historyincome: (context) => IncomeHistoryScreen(),
    RouteNames.echarts: (context) => ExpenseStatistics(),
  };
}
