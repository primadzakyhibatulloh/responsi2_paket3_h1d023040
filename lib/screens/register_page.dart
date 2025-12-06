import 'package:flutter/material.dart';
import '../data/api_service.dart';
import '../widget/success_dialog.dart'; // Pastikan import ini ada

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _register() async {
    // 1. Validasi Input
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    // 2. Mulai Loading
    setState(() => _isLoading = true);

    try {
      // 3. Panggil API Register
      bool success = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // 4. Cek Hasil
      if (success) {
        if (!mounted) return;
        
        // Tampilkan Popup Sukses
        showSuccessDialog(context, "Registrasi Berhasil! Silakan Login.", () {
          Navigator.pop(context); // Kembali ke Login setelah klik OK
        });
        
      } else {
        throw Exception('Gagal register. Email mungkin sudah digunakan.');
      }
    } catch (e) {
      // 5. Tangkap Error (Koneksi/CORS/Lainnya)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      // 6. WAJIB: Matikan Loading apa pun yang terjadi
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // SUDAH DIPERBARUI: Menambahkan nama Primamart
        title: const Text('Daftar Akun Primamart'), 
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Daftar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}