import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/annonce_details/provider_models/AnnonceImageSwiper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom_image_updated/pinch_zoom_image_updated.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector/swipedetector.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
//ajouter une image
class AnnonceImages extends StatelessWidget {
  const AnnonceImages({
    Key key,
    @required this.annonce,
  }) : super(key: key);

  final Annonce annonce;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnnonceImageSwiper(),
      child: Consumer<AnnonceImageSwiper>(
        builder: (context, annonceImagesSwiper, child) {
          return Column(
            children: [
              SwipeDetector(
                onSwipeLeft: () {
                  annonceImagesSwiper.currentImageIndex++;
                  annonceImagesSwiper.currentImageIndex %=
                      annonce.images.length;
                },
                onSwipeRight: () {
                  annonceImagesSwiper.currentImageIndex--;
                  annonceImagesSwiper.currentImageIndex +=
                      annonce.images.length;
                  annonceImagesSwiper.currentImageIndex %=
                      annonce.images.length;
                },
                child: PinchZoomImage(
                  image: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: SizedBox(
                      height: SizeConfig.screenHeight * 0.35,
                      width: SizeConfig.screenWidth * 0.75,
                      child: Image.network(
                        annonce.images[annonceImagesSwiper.currentImageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    annonce.images.length,
                    (index) =>
                        buildSmallPreview(annonceImagesSwiper, index: index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSmallPreview(AnnonceImageSwiper annonceImagesSwiper,
      {@required int index}) {
    return GestureDetector(
      onTap: () {
        annonceImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        padding: EdgeInsets.all(getProportionateScreenHeight(8)),
        height: getProportionateScreenWidth(48),
        width: getProportionateScreenWidth(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: annonceImagesSwiper.currentImageIndex == index
                  ? kPrimaryColor
                  : Colors.transparent),
        ),
        child: Image.network(annonce.images[index]),
      ),
    );
  }
}
