import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCatatanPage extends StatefulWidget {
  @override
  _UserCatatanPageState createState() => _UserCatatanPageState();
}

class _UserCatatanPageState extends State<UserCatatanPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> catatanList = [];
  bool isLoading = true; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    _fetchUserCatatanData();
  }

  // Fetching catatan data for the logged-in user
  Future<void> _fetchUserCatatanData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('catatan')
          .select()
          .eq('user_id', user.id) // Fetch only notes where user_id matches the logged-in user's ID
          .order('tanggal', ascending: false) // Order by date
          .execute();

      if (response.error == null) {
        setState(() {
          catatanList = List<Map<String, dynamic>>.from(response.data);
          isLoading = false; // Set loading to false after data is fetched
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if there's an error
        });
        print('Error fetching data: ${response.error?.message}');
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading if user is not logged in
      });
      print('User is not logged in');
    }
  }

  // Function to navigate to add new catatan page
  void _navigateToAddCatatan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCatatanPage()),
    ).then((_) {
      // Fetch the updated list after adding a new note
      _fetchUserCatatanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while data is fetching
          : catatanList.isEmpty
              ? Center(child: Text('No notes available'))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: catatanList.length,
                  itemBuilder: (context, index) {
                    final catatan = catatanList[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'Tanggal: ${catatan['tanggal']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Isi Catatan: ${catatan['isi_catatan']}'),
                            SizedBox(height: 4),
                            Text('Created At: ${catatan['created_at']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCatatan,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add Note',
      ),
    );
  }
}

class AddCatatanPage extends StatefulWidget {
  @override
  _AddCatatanPageState createState() => _AddCatatanPageState();
}

class _AddCatatanPageState extends State<AddCatatanPage> {
  final TextEditingController _isiCatatanController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  // Function to add a new catatan
  Future<void> _addCatatan() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase.from('catatan').insert({
        'user_id': user.id,
        'isi_catatan': _isiCatatanController.text,
        'tanggal': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }).execute();

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note added successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note: ${response.error?.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Catatan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _isiCatatanController,
              decoration: InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCatatan,
              child: Text('Save Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
