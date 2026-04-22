import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:get/get.dart";

import "app/routes/app_pages.dart";
import "app/routes/app_routes.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Hit Customer",
      initialRoute: AppRoutes.main,
      getPages: AppPages.routes,
    );
  }
}
