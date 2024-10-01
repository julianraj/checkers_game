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
        Widget? piece;
        if(isDark) {
          if(index < 24) { // firts 3 rows
            piece = Piece(isPlayer1: false);
          } else if(index >= 40) { // last 3 rows
            piece = Piece(isPlayer1: true);
          }
        }

        return Container(
          color: isDark ? Colors.brown : Colors.white,
          child: piece != null ? Center(child: piece) : null, // Center the piece in the cell if it exists
        );
      },
    );
  }
}

class Piece extends StatelessWidget {
  final bool isPlayer1;  // Determines if the piece belongs to player 1 or 2
  
  Piece({super.key, required this.isPlayer1});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),  // Add spacing around the piece
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlayer1 ? Colors.red : Colors.black,  // Red for player 1, black for player 2
      ),
    );
  }
}