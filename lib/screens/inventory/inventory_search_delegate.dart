import 'package:flutter/material.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/inventory.dart';
import 'package:orderly/screens/inventory/product/product_list_screen.dart';

class InventorySearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        color: Colors.blueAccent, // Change the background color
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle:
            TextStyle(color: Colors.white70), // Change the hint text color
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: Colors.white, fontSize: 18), // Change the search text color
      ),
    );
  }

  @override
  String? get searchFieldLabel => 'Search Inventory or Product';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: _searchInventoriesAndProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return ListTile(
                  title: Text(result.displayName),
                  subtitle: result.isProduct
                      ? Text('Product in ${result.inventoryName}')
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(
                          inventory: result.inventory!,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No results found.'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: _fetchSuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final suggestions = snapshot.data!;
            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName),
                  subtitle: suggestion.isProduct
                      ? Text('Product in ${suggestion.inventoryName}')
                      : null,
                  onTap: () {
                    query = suggestion.displayName;
                    showResults(context);
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No suggestions available.'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<SearchResult>> _searchInventoriesAndProducts(String query) async {
    final allInventories = await DatabaseHelper().fetchInventories();
    final List<SearchResult> results = [];

    for (var inventory in allInventories) {
      if (inventory.name.toLowerCase().contains(query.toLowerCase())) {
        results.add(SearchResult(
          displayName: inventory.name,
          isProduct: false,
          inventory: inventory,
        ));
      }

      final products = await DatabaseHelper().fetchProducts(inventory.id!);
      for (var product in products) {
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
          results.add(SearchResult(
            displayName: product.name,
            isProduct: true,
            inventoryName: inventory.name,
            inventory: inventory,
          ));
        }
      }
    }

    return results;
  }

  Future<List<SearchResult>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await _searchInventoriesAndProducts(query);
  }
}

class SearchResult {
  final String displayName;
  final bool isProduct;
  final String? inventoryName;
  final Inventory? inventory;

  SearchResult({
    required this.displayName,
    required this.isProduct,
    this.inventoryName,
    this.inventory,
  });
}
