import 'package:get/get.dart';
import '../controllers/public_ranking_controller.dart';
import '../../../services/public_ranking_service.dart';

class PublicRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicRankingService>(() => PublicRankingService());
    Get.lazyPut<PublicRankingController>(() => PublicRankingController());
  }
}
