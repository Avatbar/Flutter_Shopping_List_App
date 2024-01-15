import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-shoping-list-d2f1c-default-rtdb.firebaseio.com',
        '/items.json');
    // final url = Uri.parse('https://abc.firebaseio.com/items.json'); // Bad url for testing
    try {
      final httpResponse = await http.get(url);
      if (httpResponse.body.isEmpty || httpResponse.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (httpResponse.statusCode == 200) {
        final Map<String, dynamic> items = json.decode(httpResponse.body);
        final List<GroceryItem> loadedItems = [];
        items.forEach((key, value) {
          final category = categories.entries
              .firstWhere((element) => element.value.name == value['category'])
              .value;
          final item = GroceryItem(
            id: key,
            name: value['name'],
            quantity: int.parse(value['quantity']),
            category: category,
          );
          loadedItems.add(item);
        });
        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      } else if (httpResponse.statusCode >= 400) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load items';
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _deleteItem(GroceryItem item) async {
    final url = Uri.https(
        'flutter-shoping-list-d2f1c-default-rtdb.firebaseio.com',
        '/items/${item.id}.json');
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete ${item.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
    } else if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} deleted'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items yet!'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            final item = _groceryItems[index];
            return Dismissible(
              key: ValueKey(item.id),
              onDismissed: (direction) {
                _deleteItem(item);
              },
              background: Container(
                color: Theme.of(context).colorScheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.category.color,
                ),
                title: Text(item.name),
                subtitle: Text(item.category.name),
                trailing: Text('${item.quantity}x'),
              ),
            );
          });
    }

    if (_error.isNotEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
        ],
      ),
      body: content,
    );
  }
}
