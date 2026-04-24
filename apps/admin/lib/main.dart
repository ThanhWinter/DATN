import "package:flutter/material.dart";
import "package:core_ui/core_ui.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:get/get.dart";

import "app/routes/app_pages.dart";
import "app/routes/app_routes.dart";
import "app/services/auth_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Get.putAsync(() => AuthService().init());
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Hit Admin",
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
