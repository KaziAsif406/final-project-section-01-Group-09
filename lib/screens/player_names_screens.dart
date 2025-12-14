import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'game_board_screen.dart';

class PlayerNamesScreen extends StatefulWidget {
  final int boardSize;
  final int winLength;

  const PlayerNamesScreen({super.key, this.boardSize = 3, this.winLength = 3});

  @override
  State<PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends State<PlayerNamesScreen> {
  final TextEditingController _player1NameController = TextEditingController();
  final TextEditingController _player2NameController = TextEditingController();
  // Timer option removed for now.

  @override
  void dispose() {
    _player1NameController.dispose();
    _player2NameController.dispose();
    super.dispose();
  }

  void _startGame() {
    final player1Name = _player1NameController.text.trim().isEmpty
        ? 'Player 1'
        : _player1NameController.text.trim();

    final player2Name = _player2NameController.text.trim().isEmpty
        ? 'Player 2'
        : _player2NameController.text.trim();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameState(
            player1Name: player1Name,
            player2Name: player2Name,
            boardSize: widget.boardSize,
            winLength: widget.winLength,
          ),
          child: GameBoardScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Player Names'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 152, 212, 234),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 213, 246, 251),
              Color.fromARGB(255, 213, 246, 251),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter Player Names',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color.fromARGB(255, 91, 133, 149),
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _player1NameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        labelText: 'Player 1 Name (X)',
                        hintText: 'Enter name or leave blank',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4C5F9),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9B88C4),
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFF9B88C4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _player2NameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        labelText: 'Player 2 Name (O)',
                        hintText: 'Enter name or leave blank',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4C5F9),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9B88C4),
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFC97E7E),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _startGame(),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 20),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            114,
                            177,
                            206,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 237, 239, 240),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}