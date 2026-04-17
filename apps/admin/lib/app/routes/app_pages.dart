import "package:get/get.dart";

import "../../features/auth/presentation/views/login_view.dart";
import "../bindings/auth_binding.dart";
import "app_routes.dart";

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
  ];
}
