import 'Model.dart';

class OrderedAnnonce extends Model {
  static const String ANNONCE_UID_KEY = "annonce_uid";
  static const String ORDER_DATE_KEY = "order_date";

  String annonceUid;
  String orderDate;
  OrderedAnnonce(
    String id, {
    this.annonceUid,
    this.orderDate,
  }) : super(id);

  factory OrderedAnnonce.fromMap(Map<String, dynamic> map, {String id}) {
    return OrderedAnnonce(
      id,
      annonceUid: map[ANNONCE_UID_KEY],
      orderDate: map[ORDER_DATE_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ANNONCE_UID_KEY: annonceUid,
      ORDER_DATE_KEY: orderDate,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (annonceUid != null) map[ANNONCE_UID_KEY] = annonceUid;
    if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
    return map;
  }
}
