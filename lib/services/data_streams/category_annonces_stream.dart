import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';

class CategoryAnnoncesStream extends DataStream<List<String>> {
  final AnnonceType category;

  CategoryAnnoncesStream(this.category);
  @override
  void reload() {
    final allAnnoncesFuture =
        AnnonceDatabaseHelper().getCategoryAnnoncesList(category);
    allAnnoncesFuture.then((favAnnonces) {
      addData(favAnnonces);
    }).catchError((e) {
      addError(e);
    });
  }
}
