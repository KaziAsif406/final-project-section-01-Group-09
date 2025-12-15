import 'package:flutter/material.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  // Demo data; no backend yet
  List<Map<String, String>> get _demoMatches => [
    {
      'players': 'Asif vs Saif',
      'result': 'Asif wins',
      'board': '3x3 • Connect 3',
      'date': 'Dec 14, 2025',
    },
    {
      'players': 'Saif vs Sadia',
      'result': 'Tie',
      'board': '4x4 • Connect 4',
      'date': 'Dec 13, 2025',
    },
    {
      'players': 'Elora vs Sadia',
      'result': 'Sadia wins',
      'board': '5x5 • Connect 4',
      'date': 'Dec 12, 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final matches = _demoMatches;

    return Scaffold(
      appBar: AppBar(title: const Text('Match History'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (matches.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No matches yet — demo data shown here.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, i) {
                    final m = matches[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(m['players']!.split(' ').first[0]),
                      ),
                      title: Text(m['players']!),
                      subtitle: Text('${m['result']} • ${m['board']}'),
                      trailing: Text(
                        m['date']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                },
                child: const Text('Clear History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
