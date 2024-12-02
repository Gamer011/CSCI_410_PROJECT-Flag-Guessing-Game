import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const GuessTheFlagApp());
}

class GuessTheFlagApp extends StatelessWidget {
  const GuessTheFlagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the Flag',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF1E88E5),
            textStyle: const TextStyle(fontSize: 24),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guess the Flag',
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Guess the Flag', style: TextStyle(fontSize: 36, color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<Map<String, String>> flags = [
    {"country": "United States", "url": "https://flagcdn.com/w320/us.png"},
    {"country": "Germany", "url": "https://flagcdn.com/w320/de.png"},
    {"country": "India", "url": "https://flagcdn.com/w320/in.png"},
    {"country": "Japan", "url": "https://flagcdn.com/w320/jp.png"},
    {"country": "Canada", "url": "https://flagcdn.com/w320/ca.png"},
    {"country": "Brazil", "url": "https://flagcdn.com/w320/br.png"},
    {"country": "Australia", "url": "https://flagcdn.com/w320/au.png"},
    {"country": "France", "url": "https://flagcdn.com/w320/fr.png"},
    {"country": "South Korea", "url": "https://flagcdn.com/w320/kr.png"},
    {"country": "Italy", "url": "https://flagcdn.com/w320/it.png"},
  ];

  late List<Map<String, String>> remainingFlags;
  String correctAnswer = "";
  String correctFlagUrl = "";
  List<String> options = [];
  int score = 0;
  int attempts = 0;
  int timeRemaining = 120;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingFlags = List.from(flags);
    generateQuestion();
    startTimer();
  }

  void generateQuestion() {
    final random = Random();

    if (remainingFlags.isEmpty) {
      remainingFlags = List.from(flags);
    }

    // chooses a random flag from the remaining flags
    final chosenFlag = remainingFlags.removeAt(random.nextInt(remainingFlags.length));
    correctAnswer = chosenFlag["country"]!;
    correctFlagUrl = chosenFlag["url"]!;

    // generates 3 random options ensuring no duplicates
    Set<String> optionsSet = {correctAnswer};
    while (optionsSet.length < 4) {
      optionsSet.add(flags[random.nextInt(flags.length)]["country"]!);
    }

    options = optionsSet.toList()..shuffle();
  }

  void checkAnswer(String answer) {
    setState(() {
      if (answer == correctAnswer) score++;
      attempts++;
    });

    if (attempts < 10) {
      generateQuestion();
    } else {
      showGameOverDialog();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          timer.cancel();
          showTimeUpDialog();
        }
      });
    });
  }

  void showTimeUpDialog() {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!', style: TextStyle(color: Colors.white)),
        content: Text('You scored $score points.', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit to Main Menu', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                attempts = 0;
                timeRemaining = 120;
                remainingFlags = List.from(flags); // reset flags
                generateQuestion();
                startTimer();
              });
            },
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showGameOverDialog() {
    timer?.cancel();
    String message = score >= 8
        ? "Amazing job!"
        : score >= 5
        ? "Good work!"
        : "Keep practicing!";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over', style: TextStyle(color: Colors.white)),
        content: Text("You scored $score/10\n$message", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit to Main Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Flag', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time Remaining: $timeRemaining secs', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text('Score: $score | Attempts: $attempts/10', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Image.network(
              correctFlagUrl,
              height: 200,
              width: 260,
              loadingBuilder: (context, child, loadingProgress) =>
              loadingProgress == null ? child : const CircularProgressIndicator(),
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 100),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options.sublist(0, 2).map((option) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(option),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options.sublist(2).map((option) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(option),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
