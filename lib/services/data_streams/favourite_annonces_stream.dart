import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class FavouriteAnnoncesStream extends DataStream<List<String>> {
  @override
  void reload() {
    final favAnnoncesFuture = UserDatabaseHelper().usersFavouriteAnnoncesList;
    favAnnoncesFuture.then((favAnnonces) {
      addData(favAnnonces.cast<String>());
    }).catchError((e) {
      addError(e);
    });
  }
}
