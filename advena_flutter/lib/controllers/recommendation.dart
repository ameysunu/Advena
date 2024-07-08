import 'package:advena_flutter/controllers/sqlcontroller.dart';

class RecommendationController {
  SqlController _sqlController = SqlController();

  Future<bool> onLoadRecommendation() async {
    try {
      var isTableExists = await createRecommendationIfNotExists();
      if (isTableExists) {
        List<Map<String, dynamic>> items =
            await _sqlController.getItems("recommendation");
        print("ITEMS: $items");
        if (items.isEmpty) {
          print("Empty Recommendations");
          return false;
        } else {
          return true;
        }
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> createRecommendationIfNotExists() async {
    bool tableExists = await _sqlController.isTableExists("recommendation");
    if (!tableExists) {
      var db = await _sqlController.database;
      var createQuery =
          "CREATE TABLE recommendation (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, event TEXT NOT NULL)";
      await _sqlController.createTable(db, createQuery);

      return false;
    }

    return true;
  }
}
