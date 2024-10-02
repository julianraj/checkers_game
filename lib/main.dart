import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  List<Map<String, dynamic>?> pieces = List.filled(64, null); // Track pieces on the board (true -> player1, false -> player2, null -> empty)
  bool isPlayer1Turn = true; // Track player turns
  bool canChangeSelectedPiece = true; // Track if the selected piece can be changed

  final AudioPlayer _audioPlayer = AudioPlayer();  // Initialize audio player

  @override
  void initState() {
    super.initState();
    initPieces(); // initialize board with player pieces
  }

  @override
  void dispose() {
    _audioPlayer.dispose();  // Dispose of the audio player when not needed
    super.dispose();
  }

  void playMoveSound() async {
    await _audioPlayer.play(AssetSource('sounds/move.mp3'));  // Play move sound
  }

  void playCaptureSound() async {
    await _audioPlayer.play(AssetSource('sounds/capture.mp3'));  // Play capture sound
  }

  void playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/win.mp3'));  // Play win sound
  }

  void initPieces() {
    // Initialize player 1 (true) and player 2 (false) pieces on the board
    for (int i = 0; i < 24; i++) {
      if ((i ~/ 8) % 2 == i % 2) pieces[i] = { "isPlayer1": false, "isKing": false };  // Player 2
    }
    for (int i = 40; i < 64; i++) {
      if ((i ~/ 8) % 2 == i % 2) pieces[i] = { "isPlayer1": true, "isKing": false };  // Player 1
    }
  }

  // Function to select a piece and calculate valid moves
  void selectPiece(int index) {
    if (canChangeSelectedPiece && pieces[index]!['isPlayer1'] == isPlayer1Turn) { // Only allow selecting current player's pieces
      if (pieces[index] != null) {
        setState(() {
          selectedPieceIndex = index;
          validMoves = calculateValidMoves(index, pieces[index]!['isPlayer1'], pieces[index]!['isKing']);  // Calculate valid moves
        });
      }
    }
  }
  
  void movePiece(int index) {
    if (validMoves.contains(index)) {
      setState(() {
        pieces[index] = pieces[selectedPieceIndex!];  // Move piece to new square
        pieces[selectedPieceIndex!] = null;  // Clear the old square

        // Promote to king if reaching the opposite end
        if ((index < 8 && pieces[index]!['isPlayer1']) || (index >= 56 && !pieces[index]!['isPlayer1'])) {
          pieces[index]!['isKing'] = true;
        }

        // Check for captures
        int capturedIndex = (index + selectedPieceIndex!) ~/ 2;
        bool isCaptured = (index - selectedPieceIndex!).abs() > 9;
        if (isCaptured) {
          pieces[capturedIndex] = null;  // Remove captured piece
          playCaptureSound();
          // Check for another capture move after jumping
          List<int> furtherMoves = calculateValidMoves(index, pieces[index]!['isPlayer1'], pieces[index]!['isKing']);
          if (furtherMoves.isNotEmpty && furtherMoves.any((move) => (move - index).abs() > 9)) {
            // Keep the turn with the current player if more captures are available
            selectedPieceIndex = index;
            validMoves = furtherMoves;
            canChangeSelectedPiece = false;
            return;
          }
        } else {
          playMoveSound();
        }
        selectedPieceIndex = null;  // Deselect the piece
        validMoves = [];
        isPlayer1Turn = !isPlayer1Turn;  // Switch turns
        canChangeSelectedPiece = true;
      });
      checkForWin();
    }
  }

  // Placeholder function for calculating valid moves
  List<int> calculateValidMoves(int index, bool isPlayer1, bool isKing) {
    List<int> moves = [];
    int row = index ~/ 8;
    int col = index % 8;

    // Add simple move validation (for now, just check diagonal movement)
    if(isKing || !isPlayer1) {
      if (row < 7 && col > 0 && pieces[index + 7] == null) moves.add(index + 7);  // Down-left movement
      if (row < 6 && col > 1 && pieces[index + 7]?['isPlayer1'] == !isPlayer1 && pieces[index + 14] == null) moves.add(index + 14);  // Down-left capture
      if (row > 1 && col > 1 && pieces[index - 9]?['isPlayer1'] == !isPlayer1 && isKing && pieces[index - 18] == null) moves.add(index - 18);  // Up-left capture (KING)

      if (row < 7 && col < 7 && pieces[index + 9] == null) moves.add(index + 9);  // Down-right movement
      if (row < 6 && col < 6 && pieces[index + 9]?['isPlayer1'] == !isPlayer1 && pieces[index + 18] == null) moves.add(index + 18);  // Down-right capture
      if (row > 1 && col < 6 && pieces[index - 7]?['isPlayer1'] == !isPlayer1 && isKing && pieces[index - 14] == null) moves.add(index - 14);  // Up-right capture (KING)
    }
    if (isKing || isPlayer1) {
      if (row > 0 && col > 0 && pieces[index - 9] == null) moves.add(index - 9);  // Up-left movement
      if (row > 1 && col > 1 && pieces[index - 9]?['isPlayer1'] == !isPlayer1 && pieces[index - 18] == null) moves.add(index - 18);  // Up-left capture
      if (row < 6 && col > 1 && pieces[index + 7]?['isPlayer1'] == !isPlayer1 && isKing && pieces[index + 14] == null) moves.add(index + 14);  // Down-left capture (KING)

      if (row > 0 && col < 7 && pieces[index - 7] == null) moves.add(index - 7);  // Up-right movement
      if (row > 1 && col < 6 && pieces[index - 7]?['isPlayer1'] == !isPlayer1 && pieces[index - 14] == null) moves.add(index - 14);  // Up-right capture
      if (row < 6 && col < 6 && pieces[index + 9]?['isPlayer1'] == !isPlayer1 && isKing && pieces[index + 18] == null) moves.add(index + 18);  // Down-right capture (KING)
    }

    return moves;
  }

  void checkForWin() {
    bool player1HasPieces = pieces.any((piece) => piece?['isPlayer1'] == true);
    bool player2HasPieces = pieces.any((piece) => piece?['isPlayer1'] == false);

    if(!player2HasPieces || !player1HasPieces) {
      playWinSound();
      showWinDialog(!player2HasPieces ? "Player 2 Wins!" : "Player 1 Wins!");
    }
  }

  void showWinDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                setState(() {
                  // Reset game state for a new game
                  pieces = List.filled(64, null);
                  // Initialize pieces again
                  initPieces();
                  isPlayer1Turn = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                if (piece != null) Center(child: Piece(isPlayer1: piece['isPlayer1'], isKing: piece['isKing']))
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
  final bool  isKing;
  
  Piece({super.key, required this.isPlayer1, required this.isKing });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlayer1 ? Colors.red : Colors.black,  // Red for player 1, black for player 2
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 3)
          )
        ],
        border: Border.all(color: Colors.white, width: 2)
      ),
      child: isKing ? Center(child: Icon(Icons.star, color: Colors.white, size: 24)) : null,
    );
  }
}