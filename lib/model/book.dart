class Book {
  final int? id;
  final String judul;
  final int harga;
  final int jumlah;
  final String tanggalMasuk;
  final int volume;
  final String penulis;
  final String penerbit;

  Book({
    this.id,
    required this.judul,
    required this.harga,
    required this.jumlah,
    required this.tanggalMasuk,
    required this.volume,
    required this.penulis,
    required this.penerbit,
  });

  // Mengubah JSON dari API menjadi Object Dart
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      judul: json['judul'],
      harga: json['harga'], // Pastikan tipe data di database Integer
      jumlah: json['jumlah'],
      tanggalMasuk: json['tanggal_masuk'],
      volume: json['volume'],
      penulis: json['penulis'],
      penerbit: json['penerbit'],
    );
  }

  // Mengubah Object Dart menjadi JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'harga': harga,
      'jumlah': jumlah,
      'tanggal_masuk': tanggalMasuk,
      'volume': volume,
      'penulis': penulis,
      'penerbit': penerbit,
    };
  }
}