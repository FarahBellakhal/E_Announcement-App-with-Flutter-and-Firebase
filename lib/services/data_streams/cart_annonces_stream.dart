import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class CartAnnoncesStream extends DataStream<List<String>> {
  @override
  void reload() {
    final allAnnoncesFuture = UserDatabaseHelper().allCartAnnonceList;
    allAnnoncesFuture.then((favAnnonces) {
      addData(favAnnonces);
    }).catchError((e) {
      addError(e);
    });
  }
}
