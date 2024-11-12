import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  final String username;

  GamePage({required this.username});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String currentGuess = "Henüz tahmin yok";
  int quantityGuess = 1;
  int diceValueGuess = 1;

  Future<void> _makeGuess() async {
    try {
      final gameRoomRef = _firestore.collection('gameRoom').doc('gameRoom');

      await gameRoomRef.set({
        'currentGuess': {
          'quantity': quantityGuess,
          'diceValue': diceValueGuess,
        },
      }, SetOptions(merge: true));

      await _passTurnToNextPlayer();

      setState(() {
        currentGuess = "$quantityGuess tane $diceValueGuess";
      });
    } catch (e) {
      print("Tahmin yapılırken bir hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Tahmin yapılırken bir hata oluştu."),
      ));
    }
  }

  Future<void> _passTurnToNextPlayer() async {
    final gameRoomRef = _firestore.collection('gameRoom').doc('gameRoom');
    final playersSnapshot = await gameRoomRef.collection('players').where('isReady', isEqualTo: true).orderBy('TurnOrder').get();

    for (int i = 0; i < playersSnapshot.docs.length; i++) {
      if (playersSnapshot.docs[i].id == widget.username) {
        int nextIndex = (i + 1) % playersSnapshot.docs.length;
        String nextPlayer = playersSnapshot.docs[nextIndex].id;

        await gameRoomRef.collection('players').doc(widget.username).update({'isTurn': false});
        await gameRoomRef.collection('players').doc(nextPlayer).update({'isTurn': true});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oyun Sayfası")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Şu anki tahmin: $currentGuess",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            ElevatedButton(
              onPressed: _makeGuess,
              child: Text("Tahmin Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
