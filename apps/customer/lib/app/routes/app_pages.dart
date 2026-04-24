import "package:get/get.dart";

import "../../features/main/presentation/views/main_view.dart";
import "../bindings/main_binding.dart";

import "../../features/home/presentation/views/home_view.dart";
import "../bindings/home_binding.dart";

import "../../features/cart/presentation/views/cart_view.dart";
import "../bindings/cart_binding.dart";

import "../../features/orders/presentation/views/order_view.dart";
import "../bindings/order_binding.dart";

import "../../features/notifications/presentation/views/notification_view.dart";
import "../bindings/notification_binding.dart";


import "../../features/payment/presentation/views/checkout_view.dart";
import "../bindings/checkout_binding.dart";

import "../../features/auth/presentation/views/email_login_view.dart";
import "../../features/auth/presentation/views/forgot_password_view.dart";
import "../../features/auth/presentation/views/login_view.dart";
import "../../features/auth/presentation/views/register_view.dart";
import "../bindings/auth_binding.dart";
import "../bindings/email_login_binding.dart";
import "../bindings/forgot_password_binding.dart";
import "../bindings/register_binding.dart";
import "../bindings/otp_binding.dart";
import "../../features/auth/presentation/views/otp_view.dart";
import "../bindings/reset_password_binding.dart";
import "../../features/auth/presentation/views/reset_password_view.dart";
import "app_routes.dart";

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailLogin,
      page: () => const EmailLoginView(),
      binding: EmailLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
  ];
}
