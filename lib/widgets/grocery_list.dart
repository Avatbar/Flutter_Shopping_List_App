import 'package:flutter/material.dart';

import '../data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
      ),
      body: ListView.builder(
          itemCount: groceryItems.length,
          itemBuilder: (context, index) {
            final item = groceryItems[index];
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