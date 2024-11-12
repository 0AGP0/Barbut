import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BetPage extends StatefulWidget {
  final String username;

  BetPage({required this.username});

  @override
  _BetPageState createState() => _BetPageState();
}

class _BetPageState extends State<BetPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int betAmount = 0;

  void _placeBet() async {
    final playerRef = _firestore.collection('gameRoom').doc('gameRoom').collection('players').doc(widget.username);
    await playerRef.update({'bet': betAmount});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(title: Text("Bahis Ekranı")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bahis Miktarınızı Girin",
              style: TextStyle(fontSize: 24, color: Colors.orange[200]),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Bahis Miktarı",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  betAmount = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeBet,
              child: Text("Bahis Yap"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
            ),
          ],
        ),
      ),
    );
  }
}
