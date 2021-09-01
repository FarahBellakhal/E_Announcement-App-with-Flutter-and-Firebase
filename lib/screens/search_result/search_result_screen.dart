import 'package:flutter/material.dart';

import 'components/body.dart';
//serch screen 
class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final List<String> searchResultAnnoncesId;

  const SearchResultScreen({
    Key key,
    @required this.searchQuery,
    @required this.searchResultAnnoncesId,
    @required this.searchIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(
        searchQuery: searchQuery,
        searchResultAnnoncesId: searchResultAnnoncesId,
        searchIn: searchIn,
      ),
    );
  }
}
