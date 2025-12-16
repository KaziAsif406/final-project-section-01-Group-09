import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  final String player1Name;
  final String player2Name;
  final int boardSize;
  final int winLength;
  // Timer removed for now; reintroduce later if needed.

  late List<String> board;
  bool isPlayer1Turn = true;
  bool gameOver = false;
  String gameResult = '';
  List<int> winningCombo = [];

  // Timer-related fields removed.

  GameState({
    required this.player1Name,
    required this.player2Name,
    this.boardSize = 3,
    this.winLength = 3,
    // turnDurationSeconds removed
  }) {
    _initializeGame();
  }

  void _initializeGame() {
    board = List.filled(boardSize * boardSize, '');
    isPlayer1Turn = true;
    gameOver = false;
    gameResult = '';
    winningCombo = [];
    // Timer init removed
    notifyListeners();
  }

  void makeMove(int index) {
    if (gameOver || board[index].isNotEmpty) return;
    board[index] = isPlayer1Turn ? 'X' : 'O';
    _checkGameStatus();

    if (!gameOver) {
      isPlayer1Turn = !isPlayer1Turn;
    }

    notifyListeners();
  }

  void _checkGameStatus() {
    final n = boardSize;
    final k = winLength;

    String? winner;
    final dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final idx = r * n + c;
        final mark = board[idx];
        if (mark.isEmpty || mark == 'B') continue;
        for (final d in dirs) {
          int dr = d[0];
          int dc = d[1];
          int count = 1;
          List<int> combo = [idx];
          int rr = r + dr;
          int cc = c + dc;
          while (rr >= 0 && rr < n && cc >= 0 && cc < n && count < k) {
            final i2 = rr * n + cc;
            if (board[i2] == mark) {
              combo.add(i2);
              count++;
              rr += dr;
              cc += dc;
            } else {
              break;
            }
          }
          if (count >= k) {
            winner = mark;
            winningCombo = combo;
            break;
          }
        }
        if (winner != null) break;
      }
      if (winner != null) break;
    }

    if (winner != null) {
      gameOver = true;
      final name = winner == 'X' ? player1Name : player2Name;
      gameResult = '$name wins!';
      // Save match to Firestore
      _saveMatchToFirestore(name);
      // Timer cancelled when active (removed)
      return;
    }

    if (board.every((cell) => cell.isNotEmpty)) {
      gameOver = true;
      gameResult = "It's a tie!";
      // Save match to Firestore with 'Tie' winner
      _saveMatchToFirestore('Tie');
      // Timer cancelled when active (removed)
    }
  }

  Future<void> _saveMatchToFirestore(String winnerName) async {
    try {
      final data = {
        'winner': winnerName,
        'player1': player1Name,
        'player2': player2Name,
        'board': board.map((b) => b.isEmpty ? '0' : b).toList(),
        'date': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('matches').add(data);
    } catch (e) {
      // Swallow errors for now; optionally handle/log
    }
  }

  void resetGame() {
    _initializeGame();
  }

  void switchStartingPlayer() {
    isPlayer1Turn = !isPlayer1Turn;
    notifyListeners();
  }

  @override
  void dispose() {
    // Timer cancellation removed
    super.dispose();
  }
}
