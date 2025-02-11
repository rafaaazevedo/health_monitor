import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'paciente_detail_screen.dart';
import 'login_screen.dart';

class MedicoScreen extends StatelessWidget {
  final String medicoUid;

  MedicoScreen({required this.medicoUid});

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dados do Paciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(76, 200, 146, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: databaseRef.child('pacientes').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final patients = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patientData = Map<String, dynamic>.from(
                    patients.entries.elementAt(index).value);
                final patientName = patientData['nome'];
                final patientEmail = patientData['email'];
                final patientStatus = patientData['status'] ?? 'Ativo';

                return Card(
                  color: Colors.white,
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      patientName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patientEmail),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: patientStatus == 'Ativo'
                                  ? Colors.green
                                  : Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Status: $patientStatus',
                              style: TextStyle(
                                color: patientStatus == 'Ativo'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blueAccent,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              PacienteDetailScreen(uid: patients.entries.elementAt(index).key),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return Center(
            child: Text(
              'Nenhum paciente encontrado.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
