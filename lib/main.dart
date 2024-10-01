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

class Board extends StatefulWidget {
  Board({super.key});

  @override
  BoardState createState() => BoardState();
}
class BoardState extends State<Board> {
  int? selectedPieceIndex; // Track which piece is selected
  List<int> validMoves = []; // Track valid moves for the selected piece

  // Function to select a piece and calculate valid moves
  void selectPiece(int index) {
    setState(() {
      selectedPieceIndex = index;
      validMoves = calculateValidMoves(index, index >= 40);  // Calculate valid moves
    });
  }

  // Placeholder function for calculating valid moves
  List<int> calculateValidMoves(int index, bool isPlayer1) {
    List<int> moves = [];
    int row = index ~/ 8;
    int col = index % 8;

    // Add simple move validation (for now, just check diagonal movement)
    if(!isPlayer1) {
      if (row < 7 && col > 0) moves.add(index + 7);  // Down-left
      if (row < 7 && col < 7) moves.add(index + 9);  // Down-right
    } else {
      if (row > 0 && col > 0) moves.add(index - 9);  // Up-left
      if (row > 0 && col < 7) moves.add(index - 7);  // Up-right
    }

    return moves;
  }

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

        // Highlight the selected piece and valid move positions
        bool isSelected = index == selectedPieceIndex;
        bool isValidMove = validMoves.contains(index);

        return GestureDetector(
          onTap: () {
            selectPiece(index);
          },
          child: Container(
            color: isDark ? Colors.brown : Colors.white,
            child: Stack(
              children: [
                if (isSelected) Container(color: Colors.yellow.withOpacity(0.5)), // Highlight cell of the selected piece
                if (isValidMove) Container(color: Colors.green.withOpacity(0.5)), // Highlight cell if its a valid move
                piece != null ? Center(child: piece) : SizedBox.shrink()
              ],
            )
          )
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