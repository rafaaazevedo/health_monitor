import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class PacienteScreen extends StatefulWidget {
  final String pacienteUid;

  PacienteScreen({required this.pacienteUid});

  @override
  _PacienteScreenState createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? _pacienteData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPacienteData();
  }

  Future<void> _fetchPacienteData() async {
    try {
      DatabaseEvent event = await _database.child('pacientes/${widget.pacienteUid}').once();

      if (event.snapshot.exists) {
        setState(() {
          _pacienteData = Map<String, dynamic>.from(event.snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _pacienteData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar dados: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Monitoramento de Sinais Vitais'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pacienteData == null
              ? Center(
                  child: Text(
                    'Nenhum dado encontrado para este paciente.',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

            Text(
              'Olá, ${_pacienteData!['nome']}!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 30),
            Image.asset('lib/assets/images/Data-bro.png'),
            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dispositivo pronto para coleta de dados!'),
                    ),
                  );
                },
                splashColor: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.all(20),
                  //margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(76, 200, 146, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Iniciar Monitoramento',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalDataTile(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
        leading: Icon(
          icon,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
