import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  Stream<QuerySnapshot> get _matchesStream => FirebaseFirestore.instance
      .collection('matches')
      .orderBy('date', descending: true)
      .snapshots();

  Future<void> _clearHistory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6F0FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: Colors.black87),
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all match history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final snap = await FirebaseFirestore.instance.collection('matches').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('History cleared')));
    }
  }

  // A small selection of pastel colors to style each card differently
  final List<Color> _pastelColors = const [
    Color.fromARGB(255, 246, 170, 181), // soft pink
    Color.fromARGB(255, 160, 202, 244), // soft blue
    Color.fromARGB(255, 240, 216, 165), // soft peach
    Color.fromARGB(255, 183, 244, 161), // soft mint
    Color.fromARGB(255, 209, 171, 243), // soft lavender
  ];

  Widget _buildBoardGrid(List<String> board, {List<int>? winningCombo}) {
    final n = sqrt(board.length).toInt();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          209,
          231,
          245,
        ), // subtle preview background
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: n * 36.0,
        height: n * 36.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: n,
          ),
          itemCount: board.length,
          itemBuilder: (context, idx) {
            final val = board[idx] == '0' ? '' : board[idx];
            final isWinner = (winningCombo ?? []).contains(idx);
            final cellColor = isWinner ? const Color(0xFFFFF3C4) : Colors.white;
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              alignment: Alignment.center,
              child: Text(
                val,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.black87 : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        backgroundColor: const Color.fromARGB(255, 222, 178, 251),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 246, 245, 246), // pastel background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No matches yet — play a game to record results.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final player1 = data['player1'] ?? '';
                      final player2 = data['player2'] ?? '';
                      final winner = data['winner'] ?? '';
                      final board =
                          (data['board'] as List<dynamic>?)?.cast<String>() ??
                          [];

                      String dateText = '';
                      String timeText = '';
                      if (data['date'] != null) {
                        final ts = data['date'];
                        if (ts is Timestamp) {
                          final d = ts.toDate().toLocal();
                          dateText = DateFormat('MMM d, yyyy').format(d);
                          timeText = DateFormat('h:mm a').format(d);
                        }
                      }

                      final players = '$player1 vs $player2';
                      final result = winner == 'Tie' ? 'Tie' : '$winner wins';
                      final savedBoardSize = data['boardSize'] as int?;
                      final n = savedBoardSize ?? sqrt(board.length).toInt();
                      final boardInfo = '${n}x${n}';

                      final winLength = data['winLength'] as int?;

                      final cardColor = _pastelColors[i % _pastelColors.length];

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFFF6F0FB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                titleTextStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                contentTextStyle: const TextStyle(
                                  color: Colors.black87,
                                ),
                                title: Text(players),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Result: $result'),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Win condition: Connect ${winLength != null ? '${winLength} in a row' : 'Unknown'}',
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Board size: ${n}x${n}'),
                                      const SizedBox(height: 12),
                                      Text('Board:'),
                                      const SizedBox(height: 8),
                                      _buildBoardGrid(
                                        board,
                                        winningCombo:
                                            (data['winningCombo']
                                                    as List<dynamic>?)
                                                ?.cast<int>(),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFFF6F0FB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                titleTextStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                contentTextStyle: const TextStyle(
                                  color: Colors.black87,
                                ),
                                title: const Text('Delete Record'),
                                content: const Text(
                                  'Delete this match record? This cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await doc.reference.delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Record deleted'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: HSLColor.fromColor(cardColor)
                                        .withLightness(
                                          ((HSLColor.fromColor(
                                                        cardColor,
                                                      ).lightness -
                                                      0.12)
                                                  .clamp(0.0, 1.0))
                                              .toDouble(),
                                        )
                                        .toColor(),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        players,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '$result • Win: Connect ${winLength ?? 'Unknown'} • $boardInfo',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      dateText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _clearHistory(context),
                    child: const Text('Clear History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
