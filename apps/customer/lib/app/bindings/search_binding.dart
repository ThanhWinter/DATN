import 'package:get/get.dart';

import '../../features/search/presentation/controllers/food_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FoodSearchController());
  }
}
