// mainscreen.dart
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search'))),
            IconButton(icon: Icon(Icons.settings), onPressed: null)
          ],
        ),
      ),
      const Text('Categories'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) => const IconButton(icon: Icon(Icons.circle), onPressed: null)),
      ),
      const Spacer(),
    ]);
  }
}
