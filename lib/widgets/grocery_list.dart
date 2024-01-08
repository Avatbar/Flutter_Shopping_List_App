import 'package:flutter/material.dart';

import '../data/dummy_items.dart';
import '../models/grocery_item.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            final item = _groceryItems[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: item.category.color,
              ),
              title: Text(item.name),
              subtitle: Text(item.category.name),
              trailing: Text('${item.quantity}x'),
            );
          }
      ),
    );
  }
}