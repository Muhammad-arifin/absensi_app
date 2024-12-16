import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> absensiList;

  @override
  void initState() {
    super.initState();
    absensiList = fetchAbsensi();
  }

  Future<List<Map<String, dynamic>>> fetchAbsensi() async {
    final response = await _supabase
        .from('absensi')
        .select('id, user_id, tanggal, jam_masuk, jam_keluar, status, keterlambatan, keterangan, users(name)')
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
    return List<Map<String, dynamic>>.from(response.data);
  }

  void deleteAbsensi(int absensiId) async {
    final response = await _supabase
        .from('absensi')
        .delete()
        .eq('id', absensiId)
        .execute();

    if (response.error != null) {
      print('Failed to delete absensi: ${response.error?.message}');
    } else {
      setState(() {
        absensiList = fetchAbsensi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Karyawan'),
        backgroundColor: Colors.blueAccent,
        elevation: 0, // Removing shadow for a cleaner look
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: absensiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data absensi.'));
          } else {
            final absensi = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: absensi.length,
                itemBuilder: (context, index) {
                  final item = absensi[index];

                  // Accessing the employee's name from the nested 'users' object
                  final name = item['users']?['name'] ?? 'Tidak Diketahui';

                  return Card(
                    elevation: 4, // Shadow for card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Nama Karyawan: $name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal: ${item['tanggal']}'),
                          SizedBox(height: 4),
                          Text('Status: ${item['status']}'),
                          SizedBox(height: 4),
                          Text('Jam Masuk: ${item['jam_masuk']}'),
                          SizedBox(height: 4),
                          Text('Jam Keluar: ${item['jam_keluar']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAbsensi(item['id']),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
