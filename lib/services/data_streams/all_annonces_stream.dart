import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';

class AllAnnoncesStream extends DataStream<List<String>> {
  @override
  void reload() {
    final allAnnoncesFuture = AnnonceDatabaseHelper().allAnnoncesList;
    allAnnoncesFuture.then((favAnnonces) {
      addData(favAnnonces);
    }).catchError((e) {
      addError(e);
    });
  }
}
