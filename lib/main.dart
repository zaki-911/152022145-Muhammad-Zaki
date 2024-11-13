import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const CuacaScreen(),
    );
  }
}

class CuacaScreen extends StatefulWidget {
  const CuacaScreen({super.key});

  @override
  State<CuacaScreen> createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  final TextEditingController _ipController = TextEditingController();
  double? suhuMax;
  double? suhuMin;
  double? suhuRata;
  List<dynamic>? nilaiSuhuHumidMax;
  List<dynamic>? monthYearMax;
  bool isLoading = false;

  Future<void> fetchData(String ip) async {
    final url = 'http://$ip/api_iot/get.php';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          suhuMax = data['suhumax']?.toDouble();
          suhuMin = data['suhumin']?.toDouble();
          suhuRata = data['suhurata']?.toDouble();
          nilaiSuhuHumidMax = data['nilai_suhu_max_humid_max'];
          monthYearMax = data['month_year_max'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Info Cuaca'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bagian Profil dengan latar belakang
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/zaki.jpeg'),
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Muhammad Zaki Mahran Mufid',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan),
                  ),
                  const Text(
                    'NRP: 152022145',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input IP Server
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Masukkan IP Server',
                hintText: 'IPv4',
                labelStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),

            // Tombol CONNECT dengan dekorasi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (_ipController.text.isNotEmpty) {
                  fetchData(_ipController.text);
                }
              },
              child: const Text(
                'CONNECT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Indikator loading dengan animasi
            isLoading
                ? const CircularProgressIndicator(color: Colors.cyan)
                : Expanded(
                    child: suhuMax == null
                        ? const Center(
                            child: Text(
                              'Masukkan IP dan tekan tombol Fetch Data',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView(
                            children: [
                              // Container untuk menampilkan suhu
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blueAccent, Colors.cyan],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.thermostat_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Suhu Max: ${suhuMax ?? '-'} °C',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(
                                      'Suhu Min: ${suhuMin ?? '-'} °C',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(
                                      'Suhu Rata-rata: ${suhuRata?.toStringAsFixed(2) ?? '-'} °C',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Kontainer untuk data suhu max
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[900],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blueAccent),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Data Suhu Max:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyan),
                                    ),
                                    const SizedBox(height: 10),
                                    ...?nilaiSuhuHumidMax?.map((item) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Suhu: ${item['suhu']} °C',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            'Kecerahan: ${item['kecerahan']}%, Timestamp: ${item['timestamp']}',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Kontainer untuk Month Year Max
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[900],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blueAccent),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Month Year Max:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyan),
                                    ),
                                    const SizedBox(height: 10),
                                    ...?monthYearMax?.map((item) {
                                      return Text(
                                        'Bulan-Tahun: ${item['month_year']}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      );
                                    }).toList(),
                                  ],
                                ),
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
