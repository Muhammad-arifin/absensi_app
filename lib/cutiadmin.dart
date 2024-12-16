import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCutiPage extends StatefulWidget {
  @override
  _AdminCutiPageState createState() => _AdminCutiPageState();
}

class _AdminCutiPageState extends State<AdminCutiPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> cutiList;

  @override
  void initState() {
    super.initState();
    cutiList = fetchCuti();
  }

  Future<List<Map<String, dynamic>>> fetchCuti() async {
    // Menggunakan JOIN untuk mengambil data 'name' dari tabel 'users' berdasarkan 'user_id' di tabel 'cuti'
    final response = await _supabase
        .from('cuti')
        .select('id, user_id, tanggal_mulai, tanggal_selesai, status, jenis_cuti, keterangan, users(name)') // Pastikan relasi sudah benar
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    // Memastikan hasil query diconvert ke bentuk list of maps
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Update status cuti
  void updateCutiStatus(int cutiId, String status) async {
    if (['disetujui', 'pending', 'ditolak'].contains(status)) {
      final response = await _supabase
          .from('cuti')
          .update({'status': status})
          .eq('id', cutiId)
          .execute();

      if (response.error != null) {
        print('Failed to update cuti status: ${response.error?.message}');
      } else {
        setState(() {
          cutiList = fetchCuti(); // Refresh the list after updating
        });
      }
    } else {
      print('Invalid status: $status');
    }
  }

  // Hapus record cuti
  void deleteCuti(int cutiId) async {
    final response = await _supabase
        .from('cuti')
        .delete()
        .eq('id', cutiId)
        .execute();

    if (response.error != null) {
      print('Failed to delete cuti: ${response.error?.message}');
    } else {
      setState(() {
        cutiList = fetchCuti(); // Refresh the list after deleting
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Cuti Karyawan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cutiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data cuti.'));
          } else {
            final cuti = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: cuti.length,
                itemBuilder: (context, index) {
                  final item = cuti[index];

                  // Pastikan untuk memeriksa apakah 'name' ada di dalam data item
                  final name = item['users'] != null ? item['users']['name'] : 'Tidak Diketahui';
                  
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Nama Karyawan: $name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Mulai: ${item['tanggal_mulai']}'),
                          Text('Tanggal Selesai: ${item['tanggal_selesai']}'),
                          Text('Jenis Cuti: ${item['jenis_cuti']}'),
                          SizedBox(height: 4),
                          Text('Keterangan: ${item['keterangan'] ?? 'N/A'}'),
                          SizedBox(height: 4),
                          Text('Status: ${item['status']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item['status'] != 'disetujui')
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => updateCutiStatus(item['id'], 'disetujui'),
                            ),
                          if (item['status'] != 'ditolak')
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => updateCutiStatus(item['id'], 'ditolak'),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCuti(item['id']),
                          ),
                        ],
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
