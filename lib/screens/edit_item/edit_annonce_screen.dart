import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/edit_item/provider_models/AnnonceDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/body.dart';

class EditAnnonceScreen extends StatelessWidget {
  final Annonce annonceToEdit;

  const EditAnnonceScreen({Key key, this.annonceToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnnonceDetails(),
      child: Scaffold(
        appBar: AppBar(),
        body: Body(
          annonceToEdit: annonceToEdit,
        ),
      ),
    );
  }
}
