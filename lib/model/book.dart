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

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      judul: json['judul'],
      harga: json['harga'],
      jumlah: json['jumlah'],
      tanggalMasuk: json['tanggal_masuk'],
      volume: json['volume'],
      penulis: json['penulis'],
      penerbit: json['penerbit'],
    );
  }

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