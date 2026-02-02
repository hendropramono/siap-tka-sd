import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siap_tka_sd/models/paket_soal_app_model.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  void _showSubjectDialog(BuildContext context, PaketSoalApp paket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(paket.title),
          content: const Text('Pilih mata pelajaran:'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            Column(
              children: [
                ListTile(
                  title: const Text('Matematika'),
                  leading: const Icon(Icons.calculate, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(context);
                    // Tambahkan navigasi ke soal Matematika di sini
                  },
                ),
                ListTile(
                  title: const Text('Bahasa Indonesia'),
                  leading: const Icon(Icons.book, color: Colors.orange),
                  onTap: () {
                    Navigator.pop(context);
                    // Tambahkan navigasi ke soal Bahasa Indonesia di sini
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return "$day-$month-$year";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.onPrimary,
            ],
            stops: const [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Image.asset(
                  'assets/images/logo_bg.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('apps')
                      .doc('2A9bJTacnBTT9Bh2zfFA')
                      .collection('app_question_packages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Terjadi kesalahan'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Tidak ada paket soal'));
                    }

                    final data = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final paket = PaketSoalApp.fromJson(
                            data[index].data() as Map<String, dynamic>);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            title: Text(
                              paket.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Dibuat: ${_formatDate(paket.createdAt.toDate())}'),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: colorScheme.primary),
                            onTap: () => _showSubjectDialog(context, paket),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
