import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';

class UsersAnnoncesStream extends DataStream<List<String>> {
  @override
  void reload() {
    final usersAnnoncesFuture = AnnonceDatabaseHelper().usersAnnoncesList;
    usersAnnoncesFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
