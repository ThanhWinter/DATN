import "package:core_ui/core_ui.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:get/get.dart";

import "app/bootstrap/firebase_foreground.dart";
import "app/di/register_app_services.dart";
import "app/routes/app_pages.dart";
import "app/routes/app_routes.dart";
import "app/services/auth_service.dart";

// Hàm này PHẢI là top-level (ngoài class) — Firebase gọi nó khi app bị kill
// và có message đến. Flutter engine được đánh thức riêng, không có UI.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Đăng ký handler cho trường hợp app bị kill hoàn toàn
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");
  await Get.putAsync(() => AuthService().init());
  registerAppServices();

  registerAdminFirebaseForegroundListeners();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: kDebugMode,
      title: "Food Hit Admin",
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
