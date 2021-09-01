import 'package:e_commerce_app_flutter/models/Annonce.dart';

import 'package:flutter/material.dart';

import 'components/body.dart';

class CategoryAnnoncesScreen extends StatelessWidget {
  final AnnonceType annonceType;

  const CategoryAnnoncesScreen({
    Key key,
    @required this.annonceType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        annonceType: annonceType,
      ),
    );
  }
}
