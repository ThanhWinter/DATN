import 'package:get/get.dart';

import '../../features/auth/presentation/views/email_login_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/otp_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/main/presentation/views/main_view.dart';
import '../bindings/email_login_binding.dart';
import '../bindings/forgot_password_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/otp_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/reset_password_binding.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/notifications/presentation/views/notification_list_view.dart';
import '../../features/notifications/presentation/views/notification_push_view.dart';
import '../../features/reviews/presentation/views/review_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/notification_list_binding.dart';
import '../bindings/notification_push_binding.dart';
import '../bindings/order_detail_binding.dart';
import '../../features/orders/presentation/views/order_detail_page.dart';
import '../bindings/review_binding.dart';
import '../bindings/banner_binding.dart';
import '../bindings/settings_binding.dart';
import '../../features/banners/presentation/views/banner_view.dart';
import '../../features/profile/presentation/views/personal_info_view.dart';
import '../../features/profile/presentation/views/change_password_view.dart';
import '../../features/profile/presentation/views/help_support_view.dart';
import '../bindings/personal_info_binding.dart';
import '../bindings/change_password_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
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
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.reviews,
      page: () => const AdminReviewView(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationPush,
      page: () => const NotificationPushView(),
      binding: NotificationPushBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const NotificationListView(),
      binding: NotificationListBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailPage(),
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.banners,
      page: () => const BannerView(),
      binding: BannerBinding(),
    ),
    GetPage(
      name: AppRoutes.personalInfo,
      page: () => const PersonalInfoView(),
      binding: PersonalInfoBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportView(),
    ),
  ];
}
