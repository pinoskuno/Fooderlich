import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: use_key_in_widget_constructors
class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}

class _Search extends State<Search> {
  Future<void> _showSearch() async {
    final searchText = await showSearch<String>(
      context: context,
      delegate: SearchWithSuggestionDelegate(
        onSearchChanged: _getRecentSearchesLike,
      ),
    );
    await _saveToRecentSearches(searchText);
  }

  Future<List<String>> _getRecentSearchesLike(String keywords) async {
    final pref = await SharedPreferences.getInstance();
    final allSearches = pref.getStringList('recentSearches');
    return allSearches.where((search) => search.startsWith(keywords)).toList();
  }

  Future<void> _saveToRecentSearches(String keywords) async {
    if (keywords == null) return;
    final pref = await SharedPreferences.getInstance();

    var allSearches =
        pref.getStringList('recentSearches')?.toSet() ?? {};
    allSearches = {keywords, ...allSearches};
    pref.setStringList('recentSearches', allSearches.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xDD004D40),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: const Text('Search'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
    );
  }
}

typedef OnSearchChanged = Future<List<String>> Function(String);

class SearchWithSuggestionDelegate extends SearchDelegate<String> {
  final OnSearchChanged onSearchChanged;

  List<String> _Keywords = const [];

  SearchWithSuggestionDelegate({String searchFieldLabel, this.onSearchChanged})
      : super(searchFieldLabel: searchFieldLabel);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  void showResults(BuildContext context) {
    close(context, query);
  }

  @override
  Widget buildResults(BuildContext context) => null;

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: onSearchChanged != null ? onSearchChanged(query) : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) _Keywords = snapshot.data;
        return ListView.builder(
          itemCount: _Keywords.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.restore),
              title: Text('${_Keywords[index]}'),
              onTap: () => close(context, _Keywords[index]),
              tileColor: const Color(0xDD004D40),
              onLongPress: () => _Keywords.removeAt(index),
            );
          },
        );
      },
    );
  }
}
