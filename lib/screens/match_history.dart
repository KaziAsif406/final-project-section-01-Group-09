import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match History'), centerTitle: true),
      body: Padding(
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
                    separatorBuilder: (_, __) => const Divider(height: 12),
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
                      if (data['date'] != null) {
                        final ts = data['date'];
                        if (ts is Timestamp) {
                          final d = ts.toDate().toLocal();
                          dateText = '${d.month}/${d.day}/${d.year}';
                        }
                      }

                      final players = '$player1 vs $player2';
                      final result = winner == 'Tie' ? 'Tie' : '$winner wins';
                      final boardInfo = '${board.length} cells';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(player1.isNotEmpty ? player1[0] : '?'),
                        ),
                        title: Text(players),
                        subtitle: Text('$result • $boardInfo'),
                        trailing: Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () {
                          // Optionally show board details in a dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(players),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Result: $result'),
                                    const SizedBox(height: 8),
                                    Text('Board:'),
                                    const SizedBox(height: 8),
                                    Text(board.join(' | ')),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _clearHistory(context),
                child: const Text('Clear History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
