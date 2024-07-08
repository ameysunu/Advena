
import 'package:advena_flutter/controllers/sqlcontroller.dart';

class RecommendationController {
  SqlController _sqlController = SqlController();

  Future<List<Map<String, dynamic>>> onLoadRecommendation() async {
    return await _sqlController.getItems("recommendation");
  }

}
