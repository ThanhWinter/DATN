import 'package:get/get.dart';

class MainController extends GetxController {
  final selectedIndex = 0.obs;

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }
}
