import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCatatanPage extends StatefulWidget {
  @override
  _AdminCatatanPageState createState() => _AdminCatatanPageState();
}

class _AdminCatatanPageState extends State<AdminCatatanPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> catatanList = [];
  bool isLoading = true; // Loading flag

  @override
  void initState() {
    super.initState();
    _fetchAllCatatan();
  }

  // Fetch all catatan data (for admin view)
  Future<void> _fetchAllCatatan() async {
    final response = await supabase.from('catatan').select().execute();
    if (response.error == null) {
      setState(() {
        catatanList = List<Map<String, dynamic>>.from(response.data);
        isLoading = false; // Data fetched, stop loading
      });
    } else {
      print('Error fetching data: ${response.error?.message}');
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  // Function to delete a catatan by its id
  Future<void> _deleteCatatan(String catatanId) async {
    final response = await supabase.from('catatan').delete().eq('id', catatanId).execute();
    if (response.error == null) {
      setState(() {
        catatanList.removeWhere((catatan) => catatan['id'] == catatanId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note deleted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting note: ${response.error?.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Karyawan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading // Check if data is still loading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : catatanList.isEmpty
              ? Center(child: Text('No notes available'))
              : ListView.builder(
                  itemCount: catatanList.length,
                  itemBuilder: (context, index) {
                    final catatan = catatanList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Tanggal: ${catatan['tanggal']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Isi Catatan: ${catatan['isi_catatan']}'),
                            SizedBox(height: 4),
                            Text('Created At: ${catatan['created_at']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCatatan(catatan['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
