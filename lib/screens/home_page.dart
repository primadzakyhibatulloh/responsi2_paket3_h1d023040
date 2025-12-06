import 'package:flutter/material.dart';
import '../data/api_service.dart';
import '../model/book.dart';
import 'form_book_page.dart';
import 'login_page.dart';
import '../widget/success_dialog.dart'; // Pastikan import ini ada

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _books;

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  void _refreshBooks() {
    setState(() {
      _books = _apiService.getBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // PERUBAHAN: Nama Toko jadi Primamart
        title: const Text('Inventaris Buku Primamart'), 
        backgroundColor: Colors.brown, // Wajib Coklat
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout Logic
              await _apiService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const LoginPage())
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada buku"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(book.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Penulis: ${book.penulis} | Stok: ${book.jumlah}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormBookPage(book: book),
                            ),
                          );
                          _refreshBooks(); // Refresh setelah edit
                        },
                      ),
                      // Tombol Hapus dengan Konfirmasi
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Dialog Konfirmasi
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Hapus Buku"),
                              content: const Text("Yakin ingin menghapus buku ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ) ?? false;

                          if (confirm) {
                            bool success = await _apiService.deleteBook(book.id!);
                            
                            if (success) {
                              if (!mounted) return;
                              // Popup Sukses
                              showSuccessDialog(context, "Buku berhasil dihapus.", () {
                                _refreshBooks(); 
                              });
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gagal menghapus buku")),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormBookPage()),
          );
          _refreshBooks(); // Refresh setelah tambah buku
        },
      ),
    );
  }
}