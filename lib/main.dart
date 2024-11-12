import 'package:barbut/screens/new_player_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

void resetStatuses() async {
  final gameRoomRef = FirebaseFirestore.instance.collection('gameRoom').doc('gameRoom');
  final playersSnapshot = await gameRoomRef.collection('players').get();

  for (var doc in playersSnapshot.docs) {
    await gameRoomRef.collection('players').doc(doc.id).update({
      'isReady': false,
      'isTurn': false,
      'isEliminated': false,
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarBut',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: NewPlayerPage(),
    );
  }
}
