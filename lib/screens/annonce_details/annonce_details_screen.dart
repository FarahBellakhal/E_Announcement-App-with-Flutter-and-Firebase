import 'package:e_commerce_app_flutter/screens/annonce_details/provider_models/AnnonceActions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/body.dart';
import 'components/fab.dart';
//annonce details
class AnnonceDetailsScreen extends StatelessWidget {
  final String annonceId;

  const AnnonceDetailsScreen({
    Key key,
    @required this.annonceId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnnonceActions(),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F6F9),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F6F9),
        ),
        body: Body(
          annonceId: annonceId,
        ),
        floatingActionButton: AddToCartFAB(annonceId: annonceId),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
