import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
//annonce database 
//contient les fonctions addreview , add user annonces , delete annonce ...
class AnnonceDatabaseHelper {
  static const String ANNONCES_COLLECTION_NAME = "annonces";
  static const String REVIEWS_COLLECTOIN_NAME = "reviews";

  AnnonceDatabaseHelper._privateConstructor();
  static AnnonceDatabaseHelper _instance =
      AnnonceDatabaseHelper._privateConstructor();
  factory AnnonceDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<List<String>> searchInAnnonces(String query,
      {AnnonceType annonceType}) async {
    Query queryRef;
    if (annonceType == null) {
      queryRef = firestore.collection(ANNONCES_COLLECTION_NAME);
    } else {
      final annonceTypeStr = EnumToString.convertToString(annonceType);
      print(annonceTypeStr);
      queryRef = firestore
          .collection(ANNONCES_COLLECTION_NAME)
          .where(Annonce.ANNONCE_TYPE_KEY, isEqualTo: annonceTypeStr);
    }

    Set annoncesId = Set<String>();
    final querySearchInTags = await queryRef
        .where(Annonce.SEARCH_TAGS_KEY, arrayContains: query)
        .get();
    for (final doc in querySearchInTags.docs) {
      annoncesId.add(doc.id);
    }
    final queryRefDocs = await queryRef.get();
    for (final doc in queryRefDocs.docs) {
      final annonce = Annonce.fromMap(doc.data(), id: doc.id);
      if (annonce.title.toString().toLowerCase().contains(query) ||
          annonce.description.toString().toLowerCase().contains(query) ||
          annonce.highlights.toString().toLowerCase().contains(query) ||
          annonce.variant.toString().toLowerCase().contains(query) ||
          annonce.seller.toString().toLowerCase().contains(query)) {
        annoncesId.add(annonce.id);
      }
    }
    return annoncesId.toList();
  }

  Future<bool> addAnnonceReview(String annonceId, Review review) async {
    final reviewesCollectionRef = firestore
        .collection(ANNONCES_COLLECTION_NAME)
        .doc(annonceId)
        .collection(REVIEWS_COLLECTOIN_NAME);
    final reviewDoc = reviewesCollectionRef.doc(review.reviewerUid);
    if ((await reviewDoc.get()).exists == false) {
      reviewDoc.set(review.toMap());
      return await addUsersRatingForAnnonce(
        annonceId,
        review.rating,
      );
    } else {
      int oldRating = 0;
      oldRating = (await reviewDoc.get()).data()[Annonce.RATING_KEY];
      reviewDoc.update(review.toUpdateMap());
      return await addUsersRatingForAnnonce(annonceId, review.rating,
          oldRating: oldRating);
    }
  }

  Future<bool> addUsersRatingForAnnonce(String annonceId, int rating,
      {int oldRating}) async {
    final annonceDocRef =
        firestore.collection(ANNONCES_COLLECTION_NAME).doc(annonceId);
    final ratingsCount =
        (await annonceDocRef.collection(REVIEWS_COLLECTOIN_NAME).get())
            .docs
            .length;
    final annonceDoc = await annonceDocRef.get();
    final prevRating = annonceDoc.data()[Review.RATING_KEY];
    double newRating;
    if (oldRating == null) {
      newRating = (prevRating * (ratingsCount - 1) + rating) / ratingsCount;
    } else {
      newRating =
          (prevRating * (ratingsCount) + rating - oldRating) / ratingsCount;
    }
    final newRatingRounded = double.parse(newRating.toStringAsFixed(1));
    await annonceDocRef.update({Annonce.RATING_KEY: newRatingRounded});
    return true;
  }

  Future<Review> getAnnonceReviewWithID(
      String annonceId, String reviewId) async {
    final reviewesCollectionRef = firestore
        .collection(ANNONCES_COLLECTION_NAME)
        .doc(annonceId)
        .collection(REVIEWS_COLLECTOIN_NAME);
    final reviewDoc = await reviewesCollectionRef.doc(reviewId).get();
    if (reviewDoc.exists) {
      return Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
    }
    return null;
  }

  Stream<List<Review>> getAllReviewsStreamForAnnonceId(
      String annonceId) async* {
    final reviewesQuerySnapshot = firestore
        .collection(ANNONCES_COLLECTION_NAME)
        .doc(annonceId)
        .collection(REVIEWS_COLLECTOIN_NAME)
        .get()
        .asStream();
    await for (final querySnapshot in reviewesQuerySnapshot) {
      List<Review> reviews = List<Review>();
      for (final reviewDoc in querySnapshot.docs) {
        Review review = Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
        reviews.add(review);
      }
      yield reviews;
    }
  }

  Future<Annonce> getAnnonceWithID(String annonceId) async {
    final docSnapshot = await firestore
        .collection(ANNONCES_COLLECTION_NAME)
        .doc(annonceId)
        .get();

    if (docSnapshot.exists) {
      return Annonce.fromMap(docSnapshot.data(), id: docSnapshot.id);
    }
    return null;
  }

  Future<String> addUsersAnnonce(Annonce annonce) async {
    String uid = AuthentificationService().currentUser.uid;
    final annonceMap = annonce.toMap();
    annonce.owner = uid;
    final annoncesCollectionReference =
        firestore.collection(ANNONCES_COLLECTION_NAME);
    final docRef = await annoncesCollectionReference.add(annonce.toMap());
    await docRef.update({
      Annonce.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
          [annonceMap[Annonce.ANNONCE_TYPE_KEY].toString().toLowerCase()])
    });
    return docRef.id;
  }

  Future<bool> deleteUserAnnonce(String annonceId) async {
    final annoncesCollectionReference =
        firestore.collection(ANNONCES_COLLECTION_NAME);
    await annoncesCollectionReference.doc(annonceId).delete();
    return true;
  }

  Future<String> updateUsersAnnonce(Annonce annonce) async {
    final annonceMap = annonce.toUpdateMap();
    final annoncesCollectionReference =
        firestore.collection(ANNONCES_COLLECTION_NAME);
    final docRef = annoncesCollectionReference.doc(annonce.id);
    await docRef.update(annonceMap);
    if (annonce.annonceType != null) {
      await docRef.update({
        Annonce.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
            [annonceMap[Annonce.ANNONCE_TYPE_KEY].toString().toLowerCase()])
      });
    }
    return docRef.id;
  }

  Future<List<String>> getCategoryAnnoncesList(AnnonceType annonceType) async {
    final annoncesCollectionReference =
        firestore.collection(ANNONCES_COLLECTION_NAME);
    final queryResult = await annoncesCollectionReference
        .where(Annonce.ANNONCE_TYPE_KEY,
            isEqualTo: EnumToString.convertToString(annonceType))
        .get();
    // ignore: deprecated_member_use
    List annoncesId = List<String>();
    for (final annonce in queryResult.docs) {
      final id = annonce.id;
      annoncesId.add(id);
    }
    return annoncesId;
  }

  Future<List<String>> get usersAnnoncesList async {
    String uid = AuthentificationService().currentUser.uid;
    final annoncesCollectionReference =
        firestore.collection(ANNONCES_COLLECTION_NAME);
    final querySnapshot = await annoncesCollectionReference
        .where(Annonce.OWNER_KEY, isEqualTo: uid)
        .get();
    List usersAnnonces = List<String>();
    querySnapshot.docs.forEach((doc) {
      usersAnnonces.add(doc.id);
    });
    return usersAnnonces;
  }

  Future<List<String>> get allAnnoncesList async {
    final annonces = await firestore.collection(ANNONCES_COLLECTION_NAME).get();
    List annoncesId = List<String>();
    for (final annonce in annonces.docs) {
      final id = annonce.id;
      annoncesId.add(id);
    }
    return annoncesId;
  }

  Future<bool> updateAnnoncesImages(
      String annonceId, List<String> imgUrl) async {
    final Annonce updateAnnonce = Annonce(null, images: imgUrl);
    final docRef =
        firestore.collection(ANNONCES_COLLECTION_NAME).doc(annonceId);
    await docRef.update(updateAnnonce.toUpdateMap());
    return true;
  }

  String getPathForAnnonceImage(String id, int index) {
    String path = "products/images/$id";
    return path + "_$index";
  }
}
