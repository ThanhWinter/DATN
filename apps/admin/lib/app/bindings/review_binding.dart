import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/reviews/data/repositories/review_repository.dart';
import '../../features/reviews/presentation/controllers/review_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AdminReviewController(ReviewRepository(Get.find<IApiClient>())),
    );
  }
}
