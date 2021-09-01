import 'package:e_commerce_app_flutter/models/Model.dart';

class CartAnnonce extends Model {
  static const String ANNONCE_ID_KEY = "annonce_id";
  static const String ITEM_COUNT_KEY = "item_count";

  int itemCount;
  CartAnnonce({
    String id,
    this.itemCount = 0,
  }) : super(id);

  factory CartAnnonce.fromMap(Map<String, dynamic> map, {String id}) {
    return CartAnnonce(
      id: id,
      itemCount: map[ITEM_COUNT_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ITEM_COUNT_KEY: itemCount,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (itemCount != null) map[ITEM_COUNT_KEY] = itemCount;
    return map;
  }
}
