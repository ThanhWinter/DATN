import 'package:get/get.dart';

import '../../features/profile/data/repositories/address_repository.dart';
import '../../features/profile/presentation/controllers/address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(
      () => AddressController(Get.find<AddressRepository>()),
      fenix: true,
    );
  }
}
