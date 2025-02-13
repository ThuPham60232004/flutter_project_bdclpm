import 'package:flutter/material.dart';
import 'package:flutter_project_bdclpm/features/home/pages/home_page.dart';
import 'package:flutter_project_bdclpm/features/auth/pages/login_page.dart';
import 'package:flutter_project_bdclpm/features/type/type_page.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/manual_voice.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/pdf_excel.dart';
import 'package:flutter_project_bdclpm/features/expense/presentation/scan.dart';
import 'package:flutter_project_bdclpm/features/history/history_page.dart';
import 'package:flutter_project_bdclpm/features/history/history_income.dart';
import 'package:flutter_project_bdclpm/features/budget/add_budget.dart';
import 'package:flutter_project_bdclpm/features/listcategory/category_page.dart';
import 'package:flutter_project_bdclpm/features/budget/list_budget.dart';
import 'package:flutter_project_bdclpm/features/listcategory/expenses_category.dart';
import 'package:flutter_project_bdclpm/features/income/presentation/income.dart';
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
