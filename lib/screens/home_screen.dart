import 'package:flutter/material.dart';
import 'player_names_screen.dart';
import 'match_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _boardSize = 3;
  int _winLength = 3;

  void _onBoardSizeChanged(int size) {
    setState(() {
      _boardSize = size;
      if (_boardSize >= 6) {
        _winLength = 5;
      } else if (_boardSize == 5) {
        _winLength = 4;
      } else if (_boardSize == 4) {
        _winLength = 4;
      } else {
        _winLength = 3;
      }
    });
  }

  void _onWinLengthChanged(int length) {
    setState(() {
      _winLength = length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 246, 184, 208),
              Color.fromARGB(255, 246, 184, 208),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withOpacity(0.95),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 28.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tic Tac Toe',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF880E4F),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your match',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Board size',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            DropdownButton<int>(
                              value: _boardSize,
                              items: [3, 4, 5, 6]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text('${e} x $e'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) _onBoardSizeChanged(v);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Win condition',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            DropdownButton<int>(
                              value: _winLength,
                              items: (_boardSize >= 5)
                                  ? [4, 5]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text('Connect $e'),
                                          ),
                                        )
                                        .toList()
                                  : (_boardSize == 4)
                                  ? [4]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text('Connect $e'),
                                          ),
                                        )
                                        .toList()
                                  : [3]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text('Connect $e'),
                                          ),
                                        )
                                        .toList(),
                              onChanged: (v) {
                                if (v != null) _onWinLengthChanged(v);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.people),
                            label: const Text('PLAY'),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PlayerNamesScreen(
                                    boardSize: _boardSize,
                                    winLength: _winLength,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Board: ${_boardSize}x${_boardSize} • Win: ${_winLength}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.history),
                            label: const Text('Match History'),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MatchHistoryScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
