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
  List<bool?> pieces = List.filled(64, null); // Track pieces on the board (true -> player1, false -> player2, null -> empty)
  bool isPlayer1Turn = true; // Track player turns

  @override
  void initState() {
    super.initState();
    initPieces(); // initialize board with player pieces
  }

  void initPieces() {
    // Initialize player 1 (true) and player 2 (false) pieces on the board
    for (int i = 0; i < 24; i++) {
      if ((i ~/ 8) % 2 == i % 2) pieces[i] = false;  // Player 2
    }
    for (int i = 40; i < 64; i++) {
      if ((i ~/ 8) % 2 == i % 2) pieces[i] = true;  // Player 1
    }
  }

  // Function to select a piece and calculate valid moves
  void selectPiece(int index) {
    if (pieces[index] == isPlayer1Turn) { // Only allow selecting current player's pieces
      if (pieces[index] != null) {
        setState(() {
          selectedPieceIndex = index;
          validMoves = calculateValidMoves(index, pieces[index]!);  // Calculate valid moves
        });
      }
    }
  }

  void movePiece(int index) {
    if (validMoves.contains(index)) {
      setState(() {
        pieces[index] = pieces[selectedPieceIndex!];  // Move piece to new square
        pieces[selectedPieceIndex!] = null;  // Clear the old square
        selectedPieceIndex = null;  // Deselect the piece
        validMoves = [];

        isPlayer1Turn = !isPlayer1Turn;  // Switch turns
      });
    }
  }

  // Placeholder function for calculating valid moves
  List<int> calculateValidMoves(int index, bool isPlayer1) {
    List<int> moves = [];
    int row = index ~/ 8;
    int col = index % 8;

    // Add simple move validation (for now, just check diagonal movement)
    if(!isPlayer1) {
      if (row < 7 && col > 0 && pieces[index + 7] == null) moves.add(index + 7);  // Down-left movement
      if (row < 6 && col > 1 && pieces[index + 7] == true && pieces[index + 14] == null) moves.add(index + 14);  // Down-left capture

      if (row < 7 && col < 7 && pieces[index + 9] == null) moves.add(index + 9);  // Down-right movement
      if (row < 6 && col < 6 && pieces[index + 9] == true && pieces[index + 18] == null) moves.add(index + 18);  // Down-right capture
    } else {
      if (row > 0 && col > 0 && pieces[index - 9] == null) moves.add(index - 9);  // Up-left movement
      if (row > 1 && col > 1 && pieces[index - 9] == false && pieces[index - 18] == null) moves.add(index - 18);  // Up-left capture

      if (row > 0 && col < 7 && pieces[index - 7] == null) moves.add(index - 7);  // Up-right movement
      if (row > 1 && col < 6 && pieces[index - 7] == false && pieces[index - 14] == null) moves.add(index - 14);  // Up-right capture
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
        final piece = pieces[index];

        // Highlight the selected piece and valid move positions
        bool isSelected = index == selectedPieceIndex;
        bool isValidMove = validMoves.contains(index);

        return GestureDetector(
          onTap: () {
            if (piece != null) {
              selectPiece(index); // Select piece
            } else if (isValidMove) {
              movePiece(index); // Move to valid square
            }
          },
          child: Container(
            color: isDark ? Colors.brown : Colors.white,
            child: Stack(
              children: [
                if (isSelected) Container(color: Colors.yellow.withOpacity(0.5)), // Highlight cell of the selected piece
                if (isValidMove) Container(color: Colors.green.withOpacity(0.5)), // Highlight cell if its a valid move
                if (piece != null) Center(child: Piece(isPlayer1: piece))
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