import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/annonce_details/annonce_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
import 'package:e_commerce_app_flutter/screens/category_annonce/category_annonce_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/all_annonces_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/favourite_annonces_stream.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import '../../../utils.dart';
import '../components/home_header.dart';
import 'annonce_type_box.dart';
import 'annonces_section.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String ANNONCE_TYPE_KEY = "annonce_type";
// body qui englobe tout les sections
class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final annonceCategories = <Map>[
    <String, dynamic>{
      ICON_KEY: "assets/icons/Electronics.svg",
      TITLE_KEY: "Engineering",
      ANNONCE_TYPE_KEY: AnnonceType.Engineering,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Books.svg",
      TITLE_KEY: "Books",
      ANNONCE_TYPE_KEY: AnnonceType.Books,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Fashion.svg",
      TITLE_KEY: "Jobs",
       ANNONCE_TYPE_KEY: AnnonceType.Jobs,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Groceries.svg",
      TITLE_KEY: "Medecine",
      ANNONCE_TYPE_KEY: AnnonceType.Medecines,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Art.svg",
      TITLE_KEY: "Art",
      ANNONCE_TYPE_KEY: AnnonceType.Art,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Others.svg",
      TITLE_KEY: "Training",
      ANNONCE_TYPE_KEY: AnnonceType.Training,
    },
  ];

  final FavouriteAnnoncesStream favouriteAnnoncesStream =
      FavouriteAnnoncesStream();
  final AllAnnoncesStream allAnnoncesStream = AllAnnoncesStream();

  @override
  void initState() {
    super.initState();
    favouriteAnnoncesStream.init();
    allAnnoncesStream.init();
  }

  @override
  void dispose() {
    favouriteAnnoncesStream.dispose();
    allAnnoncesStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.length <= 0) return;
                    List<String> searchedAnnoncesId;
                    try {
                      searchedAnnoncesId = await AnnonceDatabaseHelper()
                          .searchInAnnonces(query.toLowerCase());
                      if (searchedAnnoncesId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultAnnoncesId: searchedAnnoncesId,
                              searchIn: "All Announcement",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Couldn't perform search due to some unknown reason";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$error"),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
                    bool allowed =
                        AuthentificationService().currentUserVerified;
                    if (!allowed) {
                      final reverify = await showConfirmationDialog(context,
                          "You haven't verified your email address. This action is only allowed for verified users.",
                          positiveResponse: "Resend verification email",
                          negativeResponse: "Go back");
                      if (reverify) {
                        final future = AuthentificationService()
                            .sendVerificationEmailToCurrentUser();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return FutureProgressDialog(
                              future,
                              message: Text("Resending verification email"),
                            );
                          },
                        );
                      }
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...List.generate(
                          annonceCategories.length,
                          (index) {
                            return AnnonceTypeBox(
                              icon: annonceCategories[index][ICON_KEY],
                              title: annonceCategories[index][TITLE_KEY],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryAnnoncesScreen(
                                      annonceType: annonceCategories[index]
                                          [ANNONCE_TYPE_KEY],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.5,
                  child: AnnoncesSection(
                    sectionTitle: "Announcement You Saved",
                    annoncesStreamController: favouriteAnnoncesStream,
                    emptyListMessage: "Add Announcement to Saved",
                    onAnnonceCardTapped: onAnnonceCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.8,
                  child: AnnoncesSection(
                    sectionTitle: "Explore All Items",
                    annoncesStreamController: allAnnoncesStream,
                    emptyListMessage: "Looks like all Stores are closed",
                    onAnnonceCardTapped: onAnnonceCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouriteAnnoncesStream.reload();
    allAnnoncesStream.reload();
    return Future<void>.value();
  }

  void onAnnonceCardTapped(String annonceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnonceDetailsScreen(annonceId: annonceId),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
}
