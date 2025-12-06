import 'package:flutter/material.dart';

// Fungsi ini bisa dipanggil dari halaman mana saja
void showSuccessDialog(BuildContext context, String message, VoidCallback onOk) {
  showDialog(
    context: context,
    barrierDismissible: false, // User wajib klik OK, gak bisa klik luar
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Berhasil"),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog dulu
              onOk(); // Jalankan aksi selanjutnya (misal: pindah halaman)
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}