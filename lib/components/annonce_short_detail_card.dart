import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../size_config.dart';

class AnnonceShortDetailCard extends StatelessWidget {
  final String annonceId;
  final VoidCallback onPressed;
  const AnnonceShortDetailCard({
    Key key,
    @required this.annonceId,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: FutureBuilder<Annonce>(
        future: AnnonceDatabaseHelper().getAnnonceWithID(annonceId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final annonce = snapshot.data;
            return Row(
              children: [
                SizedBox(
                  width: getProportionateScreenWidth(88),
                  child: AspectRatio(
                    aspectRatio: 0.88,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: annonce.images.length > 0
                          ? Image.network(
                              annonce.images[0],
                              fit: BoxFit.contain,
                            )
                          : Text("No Image"),
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        annonce.title,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                            text: "\₹${annonce.discountPrice}    ",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: "\₹${annonce.originalPrice}",
                                style: TextStyle(
                                  color: kTextColor,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            Logger().e(errorMessage);
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
    );
  }
}
