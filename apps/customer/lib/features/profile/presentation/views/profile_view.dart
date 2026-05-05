import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_groups.dart';
import '../widgets/profile_stats_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRetry: controller.reloadProfile,
        onSuccess: () {
          final user = controller.user.value;
          if (user == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.reloadProfile,
            color: AppColors.primaryOrange,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ProfileHeader(user: user),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.totalOrders > 0 || user.totalSaved > 0) ...[
                          ProfileStatsCard(
                            totalOrders: user.totalOrders,
                            totalSaved: user.totalSaved,
                          ),
                          const SizedBox(height: 24),
                        ],
                        const AccountSection(),
                        const SizedBox(height: 24),
                        const SupportSection(),
                        const SizedBox(height: 24),
                        const SettingsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
