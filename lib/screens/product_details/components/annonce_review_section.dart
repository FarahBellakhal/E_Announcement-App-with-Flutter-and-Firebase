import 'package:e_commerce_app_flutter/components/top_rounded_container.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'review_box.dart';

class AnnonceReviewsSection extends StatelessWidget {
  const AnnonceReviewsSection({
    Key key,
    @required this.annonce,
  }) : super(key: key);

  final Annonce annonce;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(320),
      child: Stack(
        children: [
          TopRoundedContainer(
            child: Column(
              children: [
                Text(
                  "Announcement Reviews",
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                Expanded(
                  child: StreamBuilder<List<Review>>(
                    stream: AnnonceDatabaseHelper()
                        .getAllReviewsStreamForAnnonceId(annonce.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final reviewsList = snapshot.data;
                        if (reviewsList.length == 0) {
                          return Center(
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/review.svg",
                                  color: kTextColor,
                                  width: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No reviews yet",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: reviewsList.length,
                          itemBuilder: (context, index) {
                            return ReviewBox(
                              review: reviewsList[index],
                            );
                          },
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        final error = snapshot.error;
                        Logger().w(error.toString());
                      }
                      return Center(
                        child: Icon(
                          Icons.error,
                          color: kTextColor,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: buildAnnonceRatingWidget(annonce.rating),
          ),
        ],
      ),
    );
  }

  Widget buildAnnonceRatingWidget(num rating) {
    return Container(
      width: getProportionateScreenWidth(80),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$rating",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: getProportionateScreenWidth(16),
              ),
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
