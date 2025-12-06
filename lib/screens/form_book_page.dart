import 'package:flutter/material.dart';
import '../data/api_service.dart';
import '../model/book.dart';
import '../widget/success_dialog.dart';

class FormBookPage extends StatefulWidget {
  final Book? book;
  const FormBookPage({super.key, this.book});

  @override
  State<FormBookPage> createState() => _FormBookPageState();
}

class _FormBookPageState extends State<FormBookPage> {
  final _judulCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _penerbitCtrl = TextEditingController();
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _judulCtrl.text = widget.book!.judul;
      _hargaCtrl.text = widget.book!.harga.toString();
      _jumlahCtrl.text = widget.book!.jumlah.toString();
      _tglCtrl.text = widget.book!.tanggalMasuk;
      _volumeCtrl.text = widget.book!.volume.toString();
      _penulisCtrl.text = widget.book!.penulis;
      _penerbitCtrl.text = widget.book!.penerbit;
    }
  }

  void _submit() async {
    if (_judulCtrl.text.isEmpty || _hargaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Harga wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final book = Book(
        judul: _judulCtrl.text,
        harga: int.tryParse(_hargaCtrl.text) ?? 0,
        jumlah: int.tryParse(_jumlahCtrl.text) ?? 0,
        tanggalMasuk: _tglCtrl.text,
        volume: int.tryParse(_volumeCtrl.text) ?? 0,
        penulis: _penulisCtrl.text,
        penerbit: _penerbitCtrl.text,
      );

      bool success;
      if (widget.book == null) {
        success = await _apiService.addBook(book);
      } else {
        success = await _apiService.updateBook(widget.book!.id!, book);
      }

      if (success) {
        if (!mounted) return;
        String message = widget.book == null 
            ? "Buku berhasil ditambahkan!" 
            : "Buku berhasil diperbarui!";
            
        showSuccessDialog(context, message, () {
          Navigator.pop(context);
        });
      } else {
        throw Exception("Gagal menyimpan data ke server.");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? "Tambah Buku Primamart" : "Edit Buku Primamart"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _judulCtrl, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: _hargaCtrl, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: _jumlahCtrl, decoration: const InputDecoration(labelText: "Jumlah"), keyboardType: TextInputType.number),
            TextField(controller: _tglCtrl, decoration: const InputDecoration(labelText: "Tanggal Masuk (YYYY-MM-DD)")),
            TextField(controller: _volumeCtrl, decoration: const InputDecoration(labelText: "Volume"), keyboardType: TextInputType.number),
            TextField(controller: _penulisCtrl, decoration: const InputDecoration(labelText: "Penulis")),
            TextField(controller: _penerbitCtrl, decoration: const InputDecoration(labelText: "Penerbit")),
            const SizedBox(height: 20),
            
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, 
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50)
                  ),
                  onPressed: _submit,
                  child: Text(widget.book == null ? "Simpan" : "Update"),
                )
          ],
        ),
      ),
    );
  }
}