import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BalancePage.dart';

class NewPlayerPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addNewPlayer(String username, BuildContext context) async {
    final gameRoomRef = _firestore.collection('gameRoom').doc('gameRoom');
    final playerRef = gameRoomRef.collection('players').doc(username);

    final playerSnapshot = await playerRef.get();
    if (!playerSnapshot.exists) {
      // Yeni kullanıcıysa başlangıç bilgilerini kaydet
      await playerRef.set({
        'gold': 50,
        'silver': 0,
        'copper': 0,
        'isEliminated': false,
        'isReady': false,
        'bet': 0,
        'isTurn': false,
        'turnOrder': DateTime.now().millisecondsSinceEpoch,
        'dice': List.generate(5, (_) => (1 + Random().nextInt(6))),
      });
    } else {
      // Mevcut kullanıcıysa yalnızca statüleri sıfırla
      await playerRef.update({
        'isEliminated': false,
        'isReady': false,
        'isTurn': false,
        'turnOrder': DateTime.now().millisecondsSinceEpoch,
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BalancePage(username: username),
      ),
    );
  }

  void _enterBalancePage(BuildContext context) {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      addNewPlayer(username, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lütfen geçerli bir kullanıcı adı giriniz."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "BarBut",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[200],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  labelText: "Kullanıcı Adı",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _enterBalancePage(context),
                child: Text("Giriş Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
