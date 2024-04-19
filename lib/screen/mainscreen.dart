// mainscreen.dart
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search'))),
            IconButton(icon: Icon(Icons.settings), onPressed: null)
          ],
        ),
      ),
      Text('Categories'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) => IconButton(icon: Icon(Icons.circle), onPressed: null)),
      ),
      Spacer(),
    ]);
  }
}
