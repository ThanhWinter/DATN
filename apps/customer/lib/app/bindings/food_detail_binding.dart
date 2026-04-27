import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/home/data/repositories/food_repository.dart';
import '../../features/home/presentation/controllers/food_detail_controller.dart';
import '../../features/interactions/data/repositories/interaction_repository.dart';

class FoodDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoodRepository>(
      () => FoodRepository(Get.find<IApiClient>()),
    );
    Get.lazyPut<FoodDetailController>(
      () => FoodDetailController(
        Get.find<FoodRepository>(),
        Get.find<InteractionRepository>(),
      ),
    );
  }
}
