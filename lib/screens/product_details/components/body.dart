import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/product_details/components/annonce_actions_section.dart';
import 'package:e_commerce_app_flutter/screens/product_details/components/annonce_images.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'annonce_review_section.dart';

class Body extends StatelessWidget {
  final String annonceId;

  const Body({
    Key key,
    @required this.annonceId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: FutureBuilder<Annonce>(
            future: AnnonceDatabaseHelper().getAnnonceWithID(annonceId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final annonce = snapshot.data;
                return Column(
                  children: [
                    AnnonceImages(annonce: annonce),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    AnnonceActionsSection(annonce: annonce),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    AnnonceReviewsSection(annonce: annonce),
                    SizedBox(height: getProportionateScreenHeight(100)),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                Logger().e(error);
              }
              return Center(
                child: Icon(
                  Icons.error,
                  color: kTextColor,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
