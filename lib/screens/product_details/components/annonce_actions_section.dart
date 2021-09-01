import 'package:e_commerce_app_flutter/components/top_rounded_container.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/product_details/components/annonce_description.dart';
import 'package:e_commerce_app_flutter/screens/product_details/provider_models/AnnonceActions.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../size_config.dart';
import '../../../utils.dart';

class AnnonceActionsSection extends StatelessWidget {
  final Annonce annonce;

  const AnnonceActionsSection({
    Key key,
    @required this.annonce,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        Stack(
          children: [
            TopRoundedContainer(
              child: AnnonceDescription(annonce: annonce),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: buildFavouriteButton(),
            ),
          ],
        ),
      ],
    );
    UserDatabaseHelper().isAnnonceFavourite(annonce.id).then(
      (value) {
        final annonceActions =
            Provider.of<AnnonceActions>(context, listen: false);
        annonceActions.annonceFavStatus = value;
      },
    ).catchError(
      (e) {
        Logger().w("$e");
      },
    );
    return column;
  }

  Widget buildFavouriteButton() {
    return Consumer<AnnonceActions>(
      builder: (context, annonceDetails, child) {
        return InkWell(
          onTap: () async {
            bool allowed = AuthentificationService().currentUserVerified;
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
            bool success = false;
            final future = UserDatabaseHelper()
                .switchAnnonceFavouriteStatus(
                    annonce.id, !annonceDetails.annonceFavStatus)
                .then(
              (status) {
                success = status;
              },
            ).catchError(
              (e) {
                Logger().e(e.toString());
                success = false;
              },
            );
            await showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  future,
                  message: Text(
                    annonceDetails.annonceFavStatus
                        ? "Removing from Saved"
                        : "Adding to Saved",
                  ),
                );
              },
            );
            if (success) {
              annonceDetails.switchAnnonceFavStatus();
            }
          },
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(8)),
            decoration: BoxDecoration(
              color: annonceDetails.annonceFavStatus
                  ? Color(0xFFFFE6E6)
                  : Color(0xFFF5F6F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(8)),
              child: Icon(
                Icons.save,
                color: annonceDetails.annonceFavStatus
                    ? Color(0xFFFF4848)
                    : Color(0xFFD8DEE4),
              ),
            ),
          ),
        );
      },
    );
  }
}
