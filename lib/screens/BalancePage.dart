import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BalancePage extends StatefulWidget {
  final String username;

  BalancePage({required this.username});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int gold = 0;
  int silver = 0;
  int copper = 0;
  int amount = 0;
  String selectedCurrency = "gold";

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final playerRef = _firestore.collection('gameRoom').doc('gameRoom').collection('players').doc(widget.username);
    final playerData = await playerRef.get();

    if (playerData.exists) {
      setState(() {
        gold = playerData.data()?['gold'] ?? 0;
        silver = playerData.data()?['silver'] ?? 0;
        copper = playerData.data()?['copper'] ?? 0;
      });
    }
  }

  Future<void> _updateCurrency(int change) async {
    final playerRef = _firestore.collection('gameRoom').doc('gameRoom').collection('players').doc(widget.username);

    setState(() {
      switch (selectedCurrency) {
        case "gold":
          gold += change;
          break;
        case "silver":
          silver += change;
          while (silver >= 10) {
            silver -= 10;
            gold += 1;
          }
          while (silver < 0 && gold > 0) {
            silver += 10;
            gold -= 1;
          }
          break;
        case "copper":
          copper += change;
          while (copper >= 10) {
            copper -= 10;
            silver += 1;
          }
          while (copper < 0 && silver > 0) {
            copper += 10;
            silver -= 1;
          }
          break;
      }
    });

    await playerRef.set({
      'gold': gold,
      'silver': silver,
      'copper': copper,
    }, SetOptions(merge: true));

    _controller.forward(from: 0.0); // Animasyonu tetikleyin
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBalanceTable() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.brown[800],
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Kullanıcı Bakiyeleri",
                style: TextStyle(fontSize: 24, color: Colors.orange[200], fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.orange[200]),
                title: Text("Kullanıcı Adı: ${widget.username}", style: TextStyle(color: Colors.white)),
                subtitle: Text("Altın: $gold, Gümüş: $silver, Bakır: $copper", style: TextStyle(color: Colors.white70)),
              ),
              // Diğer oyuncuların bakiyelerini burada listeleyebilirsiniz
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(
        title: Text("Bakiyeniz"),
        backgroundColor: Colors.brown[800],
        actions: [
          IconButton(
            icon: Icon(Icons.table_chart, color: Colors.orange[200]),
            onPressed: _showBalanceTable,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'money_bag.png', // Kese resmi dosya yolu
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            Text("Altın: $gold", style: TextStyle(fontSize: 24, color: Colors.orange[200])),
            Text("Gümüş: $silver", style: TextStyle(fontSize: 24, color: Colors.orange[200])),
            Text("Bakır: $copper", style: TextStyle(fontSize: 24, color: Colors.orange[200])),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Miktar Girin",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      amount = int.tryParse(value) ?? 0;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    dropdownColor: Colors.brown[800],
                    style: TextStyle(color: Colors.orange[200]),
                    value: selectedCurrency,
                    items: [
                      DropdownMenuItem(child: Text("Altın"), value: "gold"),
                      DropdownMenuItem(child: Text("Gümüş"), value: "silver"),
                      DropdownMenuItem(child: Text("Bakır"), value: "copper"),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateCurrency(amount),
                        child: Text("Ekle"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _updateCurrency(-amount),
                        child: Text("Çıkar"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
