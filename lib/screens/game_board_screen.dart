import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_control/game_state.dart';
import 'home_screen.dart';
import 'player_names_screen.dart';
import 'match_history.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  // UI-only state
  bool _showSettingsMenu = false;

  void _toggleSettingsMenu() {
    setState(() => _showSettingsMenu = !_showSettingsMenu);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 204, 255),
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 206, 161, 235),
      ),
      body: Container(
        color: const Color.fromARGB(255, 235, 204, 255),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!state.gameOver) ...[
                        Text(
                          state.isPlayer1Turn
                              ? "${state.player1Name}'s Turn"
                              : "${state.player2Name}'s Turn",
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Playing as: ${state.isPlayer1Turn ? 'X' : 'O'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 6),
                      ] else ...[
                        Text(
                          state.gameResult,
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 220, 181, 247),
                          const Color.fromARGB(255, 224, 183, 252),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: state.boardSize,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: state.boardSize * state.boardSize,
                      itemBuilder: (context, index) {
                        final isWinningCell = state.winningCombo.contains(
                          index,
                        );
                        return GestureDetector(
                          onTap: () => state.makeMove(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              color: isWinningCell
                                  ? Colors.yellow.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: isWinningCell
                                    ? Colors.orange
                                    : Colors.blue.shade200,
                                width: isWinningCell ? 3 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                child: state.board[index] == 'X'
                                    ? Icon(
                                        Icons.close,
                                        key: ValueKey('X$index'),
                                        size: 52,
                                        color: Colors.indigo.shade700,
                                      )
                                    : state.board[index] == 'O'
                                    ? Icon(
                                        Icons.circle_outlined,
                                        key: ValueKey('O$index'),
                                        size: 52,
                                        color: Colors.redAccent.shade700,
                                      )
                                    : SizedBox(
                                        key: ValueKey('e$index'),
                                        width: 0,
                                        height: 0,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            178,
                            133,
                            196,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'New Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FloatingActionButton.small(
            onPressed: _toggleSettingsMenu,
            backgroundColor: const Color.fromARGB(255, 198, 148, 218),
            tooltip: 'Settings',
            child: AnimatedRotation(
              turns: _showSettingsMenu ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.settings),
            ),
          ),
          const SizedBox(width: 12),
          if (_showSettingsMenu) ...[
            AnimatedOpacity(
              opacity: _showSettingsMenu ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: AlwaysStoppedAnimation(_showSettingsMenu ? 1.0 : 0.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    _toggleSettingsMenu();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PlayerNamesScreen(
                          boardSize: state.boardSize,
                          winLength: state.winLength,
                        ),
                      ),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 232, 159, 245),
                  tooltip: 'Change Player',
                  child: const Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: _showSettingsMenu ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: AlwaysStoppedAnimation(_showSettingsMenu ? 1.0 : 0.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    state.switchStartingPlayer();
                    _toggleSettingsMenu();
                  },
                  backgroundColor: const Color.fromARGB(255, 248, 217, 125),
                  tooltip: 'Switch Starting Player',
                  child: const Icon(Icons.swap_horiz),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: _showSettingsMenu ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: AlwaysStoppedAnimation(_showSettingsMenu ? 1.0 : 0.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    _toggleSettingsMenu();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MatchHistoryScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 135, 206, 250),
                  tooltip: 'Match History',
                  child: const Icon(Icons.history),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: _showSettingsMenu ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: AlwaysStoppedAnimation(_showSettingsMenu ? 1.0 : 0.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    state.resetGame();
                    _toggleSettingsMenu();
                  },
                  backgroundColor: const Color.fromARGB(255, 245, 71, 71),
                  tooltip: 'Clear Board',
                  child: const Icon(Icons.delete),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
