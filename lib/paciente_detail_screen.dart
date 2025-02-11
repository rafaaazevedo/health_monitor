import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PacienteDetailScreen extends StatelessWidget {
  final String uid;

  PacienteDetailScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dados Vitais', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(76, 200, 146, 1),
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white
      ),
      body: StreamBuilder(
        stream: databaseRef.child('pacientes/$uid/dados_vitais').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Gráfico ECG',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
 
                  // ECG
                  data['ecg'] != null && data['ecg'] is List && data['ecg'].isNotEmpty && !data['ecg'].contains('placeholder')
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _buildECGGraph(data['ecg']), // cria um Card personalidado
                        )
                      : _buildVitalCard(
                          title: 'ECG',
                          value: 'Sem Dados',
                          statusColor: Colors.grey,
                          icon: Icons.monitor_heart_outlined,
                      ),

                  // Batimentos por Minuto (BPM)
                  _buildVitalCard(
                    title: 'Batimentos por Minuto (BPM)',
                    value: data['bpm'] != null ? '${data['bpm']}' : 'Sem Dados',
                    statusColor: data['bpm'] != null ? Colors.red : Colors.grey,
                    icon: Icons.favorite,
                  ),

                  // Temperatura
                  _buildVitalCard(
                    title: 'Temperatura',
                    value: '${data['temperatura']} °C',
                    statusColor: _getTemperatureColor((data['temperatura'] as num).toDouble()),
                    icon: Icons.thermostat,
                  ),

                  // Umidade
                  _buildVitalCard(
                    title: 'Umidade',
                    value: '${(data['umidade'] as num).toDouble()} %',
                    statusColor: _getHumidityColor((data['umidade'] as num).toDouble()),
                    icon: Icons.water_damage,
                  ),

                  // Movimento
                  _buildVitalCard(
                    title: 'Movimento',
                    value: (data['movimento'] == 1) ? 'Detectado' : 'Não Detectado',
                    statusColor: (data['movimento'] == 1) ? Colors.orange : Colors.green,
                    icon: Icons.directions_walk,
                  ),

                  // Última Atualização
                  _buildVitalCard(
                    title: 'Última Atualização',
                    value: '${data['data_hora_ultima_atualizacao']}',
                    statusColor: Colors.grey,
                    icon: Icons.update,
                  ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Função que cria os cards para cada dado
  Widget _buildVitalCard({
    required String title,
    required String value,
    required Color statusColor,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: statusColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, color: statusColor),
        tileColor: Colors.white,
      ),
    );
  }

  // Função que retorna a cor para a temperatura com base no valor
  Color _getTemperatureColor(double temp) {
    if (temp < 35) {
      return Colors.blue; // Baixa temperatura
    } else if (temp > 37.5) {
      return Colors.red; // Alta temperatura
    } else {
      return Colors.green; // Normal
    }
  }

  // Função que retorna a cor para a umidade com base no valor
  Color _getHumidityColor(double humidity) {
    if (humidity < 30) {
      return Colors.red; // Baixa umidade
    } else if (humidity > 60) {
      return Colors.blue; // Alta umidade
    } else {
      return Colors.green; // Normal
    }
  }

  // Função para gerar o gráfico do ECG
  Widget _buildECGGraph(List<dynamic> ecgData) {
  // Converter os dados de ECG para uma lista de pontos para o gráfico
  List<FlSpot> spots = [];
  for (int i = 0; i < ecgData.length && i < 30; i++) {
    // Garantir que o valor de ecgData[i] seja numérico antes de fazer o cast
    double value = 0.0;  // Valor padrão

    // Tentar converter o valor de ecgData[i] para um número
    if (ecgData[i] is num) {
      value = (ecgData[i] as num).toDouble();
    } else {
      // Se o valor for uma string ou outro tipo, tentamos converter
      value = double.tryParse(ecgData[i].toString()) ?? 0.0;
    }

    spots.add(FlSpot(i.toDouble(), value));
  }

  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,  // Largura 100% disponível
        height: 250,  // Altura do gráfico
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black, width: 1)),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
