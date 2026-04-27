import 'package:get/get.dart';

import '../../features/interactions/data/repositories/interaction_repository.dart';
import '../../features/interactions/presentation/controllers/review_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
      () => ReviewController(Get.find<InteractionRepository>()),
    );
  }
}
