import 'package:flutter/material.dart';

void main() {
  runApp(CheckersGame());
}

class CheckersGame extends StatelessWidget {
  CheckersGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkers Game',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Checkers Game'),
        ),
        body: Board(),  // Add the Board widget here
      ),
    );
  }
}

class Board extends StatelessWidget {
  Board({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 64,  // 8x8 board = 64 squares
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,  // 8 columns
      ),
      itemBuilder: (context, index) {
        final isDark = (index ~/ 8) % 2 == 0
            ? index % 2 == 1
            : index % 2 == 0;  // Alternate light and dark squares
        return Container(
          color: isDark ? Colors.brown : Colors.white,
        );
      },
    );
  }
}