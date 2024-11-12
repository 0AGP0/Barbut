/*import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_page.dart';

class GameRoomPage extends StatefulWidget {
  final String username;

  GameRoomPage({required this.username});

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isReady = false;
  int turnOrder = 0;

  Future<void> _setReadyStatus() async {
    final gameRoomRef = _firestore.collection('gameRoom').doc('gameRoom');
    final playerRef = gameRoomRef.collection('players').doc(widget.username);

    await playerRef.set({
      'username': widget.username,
      'isReady': true,
      'isTurn': false,
      'TurnOrder': turnOrder,
      'dice': List.generate(5, (_) => (1 + Random().nextInt(6))),
      'bet': 0,
      'gold': 50,
      'silver': 0,
      'copper': 0,
    }, SetOptions(merge: true));

    setState(() {
      isReady = true;
    });
  }

  Future<void> _startGame() async {
    final gameRoomRef = _firestore.collection('gameRoom').doc('gameRoom');
    final readyPlayersSnapshot = await gameRoomRef.collection('players').where('isReady', isEqualTo: true).get();

    if (readyPlayersSnapshot.docs.length >= 2) {
      List<String> readyPlayers = readyPlayersSnapshot.docs.map((doc) => doc.id).toList();
      for (int i = 0; i < readyPlayers.length; i++) {
        await gameRoomRef.collection('players').doc(readyPlayers[i]).update({
          'TurnOrder': i + 1,
          'isTurn': i == 0, // Sadece ilk oyuncunun sırası gelsin
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(username: widget.username, readyPlayers: readyPlayers),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Oyun başlatmak için en az iki oyuncu hazır olmalı."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(title: Text("Oyun Odası - Hazır Ol")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isReady ? null : _setReadyStatus,
              child: Text("Hazır Ol"),
            ),
            ElevatedButton(
              onPressed: isReady ? _startGame : null,
              child: Text("Oyunu Başlat"),
            ),
          ],
        ),
      ),
    );
  }
}*/
