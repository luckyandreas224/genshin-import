import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_colors.dart';

void main() => runApp(const GenshinImportApp());

class GenshinImportApp extends StatelessWidget {
  const GenshinImportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      initialRoute: AppRoutes.shell,
      routes: AppRoutes.routes,
    );
  }
}
