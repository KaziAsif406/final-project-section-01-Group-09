import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  final String player1Name;
  final String player2Name;
  final int boardSize;
  final int winLength;
  final int turnDurationSeconds; // per-turn timer seconds (0 = off)

  late List<String> board;
  bool isPlayer1Turn = true;
  bool gameOver = false;
  String gameResult = '';
  List<int> winningCombo = [];

  // Timer-related fields
  int _timeLeft = 0;
  Timer? _turnTimer;

  GameState({
    required this.player1Name,
    required this.player2Name,
    this.boardSize = 3,
    this.winLength = 3,
    this.turnDurationSeconds = 0,
  }) {
    _initializeGame();
  }

  void _initializeGame() {
    board = List.filled(boardSize * boardSize, '');
    isPlayer1Turn = true;
    gameOver = false;
    gameResult = '';
    winningCombo = [];
    _timeLeft = turnDurationSeconds;
    _startTurnTimerIfNeeded();
    notifyListeners();
  }

  void makeMove(int index) {
    if (gameOver || board[index].isNotEmpty) return;
    board[index] = isPlayer1Turn ? 'X' : 'O';
    _checkGameStatus();

    if (!gameOver) {
      isPlayer1Turn = !isPlayer1Turn;
      // reset timer for next player
      _timeLeft = turnDurationSeconds;
      _startTurnTimerIfNeeded();
    } else {
      // stop timer when game ends
      _stopTurnTimer();
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
      // stop timer
      _stopTurnTimer();
      return;
    }

    if (board.every((cell) => cell.isNotEmpty)) {
      gameOver = true;
      gameResult = "It's a tie!";
      // Save match to Firestore
      _saveMatchToFirestore('Tie');
      // stop timer
      _stopTurnTimer();
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
        'winLength': winLength,
        'boardSize': boardSize,
        'winningCombo': winningCombo,
        'turnDurationSeconds': turnDurationSeconds,
      };
      await FirebaseFirestore.instance.collection('matches').add(data);
    } catch (e) {
      // Swallow errors for now; optionally handle/log
    }
  }

  void resetGame() {
    _initializeGame();
    notifyListeners();
  }

  int get remainingTime => _timeLeft;

  void _startTurnTimerIfNeeded() {
    _stopTurnTimer();
    if (turnDurationSeconds <= 0) return;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (gameOver) return;
      if (_timeLeft > 0) {
        _timeLeft -= 1;
        notifyListeners();
      }
      if (_timeLeft <= 0) {
        // time up: transfer turn
        if (!gameOver) {
          isPlayer1Turn = !isPlayer1Turn;
          _timeLeft = turnDurationSeconds;
          notifyListeners();
        }
      }
    });
  }

  void _stopTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void switchStartingPlayer() {
    isPlayer1Turn = !isPlayer1Turn;
    // reset timer for the switched player
    _timeLeft = turnDurationSeconds;
    _startTurnTimerIfNeeded();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTurnTimer();
    super.dispose();
  }
}
