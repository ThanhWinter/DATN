import 'package:get/get.dart';

import '../../features/interactions/data/repositories/interaction_repository.dart';
import '../../features/interactions/presentation/controllers/favorite_controller.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteController>(
      () => FavoriteController(Get.find<InteractionRepository>()),
    );
  }
}
