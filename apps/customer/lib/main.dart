import "package:flutter/material.dart";
import "package:get/get.dart";

import "app/routes/app_pages.dart";
import "app/routes/app_routes.dart";

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Hit Customer",
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
