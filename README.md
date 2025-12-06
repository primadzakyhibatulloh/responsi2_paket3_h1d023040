# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile berbasis **Flutter** untuk manajemen inventaris barang (Buku) di supermarket "Primamart". Aplikasi ini menggunakan **Laravel** sebagai Backend API.

---

## 👤 Identitas Mahasiswa
| Atribut | Keterangan |
| :--- | :--- |
| **Nama** | [ISI NAMA LENGKAP KAMU DISINI] |
| **NIM** | H1D023040 |
| **Shift Baru** | [ISI SHIFT BARU, Contoh: E] |
| **Shift Asal** | [ISI SHIFT ASAL, Contoh: A] |

---

## 🎥 Video Demo Aplikasi
Berikut adalah link video demonstrasi penggunaan aplikasi:
**[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]**
*(Catatan: Upload video ke YouTube atau Google Drive, lalu tempel link-nya di atas)*

---

## 🔌 Spesifikasi API (Laravel)
Backend dibangun menggunakan framework Laravel dengan fitur Token-based Authentication (Sanctum).

### 1. Authentication
| Method | Endpoint | Deskripsi | Parameter Body (JSON) |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Mendaftarkan akun baru | `name`, `email`, `password` |
| `POST` | `/api/login` | Masuk & mendapatkan Token | `email`, `password` |
| `POST` | `/api/logout` | Hapus token (Keluar) | _(Header Authorization: Bearer Token)_ |

### 2. Inventaris Buku (CRUD)
Semua endpoint di bawah membutuhkan Header: `Authorization: Bearer <token>`

| Method | Endpoint | Deskripsi | Parameter Body (JSON) |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/books` | Mengambil semua data buku | - |
| `POST` | `/api/books` | Menambah buku baru | `judul`, `harga`, `jumlah`, `tanggal_masuk`, `volume`, `penulis`, `penerbit` |
| `PUT` | `/api/books/{id}` | Mengupdate data buku | `judul`, `harga`, `jumlah`, `tanggal_masuk`, `volume`, `penulis`, `penerbit` |
| `DELETE` | `/api/books/{id}` | Menghapus buku | - |

---

## 💻 Penjelasan Kode Program (Flutter)

### 1. Halaman Login (`lib/screens/login_page.dart`)

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Variabel State** | Pengelolaan Data | Menggunakan `_emailController` dan `_passwordController` untuk membaca input secara real-time dan `_isLoading` untuk mengelola status *loading*. |
| **`_login() async`** | Logika Bisnis | Fungsi utama yang bersifat **asinkron**. Memicu `setState` untuk memulai *loading* sebelum memanggil API. |
| **`Navigator.pushReplacement(...)`** | Navigasi & Keamanan | Jika login sukses, menggunakan `pushReplacement` untuk navigasi ke `HomePage`. Ini adalah praktik keamanan untuk **mencegah** user kembali ke halaman login setelah berhasil masuk. |
| **Error Handling** | UI Feedback | Jika login gagal, status *loading* dihentikan dan pesan error ditampilkan melalui `SnackBar` (misalnya, "Cek email/password"). |
| **`AppBar` Title** | Branding | Judul disetel ke **'Login Primamart'** dan diwarnai **coklat** (`Colors.brown`) untuk konsistensi branding. |

### 2. Halaman Daftar (`lib/screens/register_page.dart`)

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Error/Safety** | Robustness | Menggunakan blok **`try-catch-finally`** di fungsi `_register()`. Blok `finally` menjamin status `_isLoading` menjadi `false` bahkan jika terjadi error koneksi yang tidak terduga (mencegah *spinner stuck*). |
| **Success Logic** | Feedback & Navigasi | Setelah sukses, menampilkan **`showSuccessDialog`** (popup) kepada user. Callback `onOk` pada dialog memicu `Navigator.pop(context)` untuk kembali ke halaman Login. |
| **Validasi Awal** | Input Safety | Memastikan semua kolom input diisi. Jika tidak, fungsi dihentikan (`return`) dan pesan peringatan `SnackBar` ditampilkan. |
| **Throw Exception** | Flow Control | Digunakan di blok `else` (jika `success` dari API adalah `false`) untuk secara eksplisit memicu blok `catch` dan menampilkan pesan error kepada user. |

### 3. Halaman Utama (`lib/screens/home_page.dart`)

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **`FutureBuilder`** | Data Rendering | Widget yang paling efisien untuk memuat data asinkron. Ia otomatis menangani 3 status: *waiting* (menampilkan spinner), *error* (jika gagal), dan *hasData* (menampilkan list buku). |
| **`_refreshBooks()`** | State Management | Fungsi yang sangat vital. Dipanggil setelah `initState` dan setelah kembali dari halaman CRUD/hapus untuk memaksa pembaruan UI dengan data terbaru dari server. |
| **Tombol Hapus** | CRUD Safety | Menggunakan kombinasi `showDialog` (untuk konfirmasi Yakin Hapus) dan memanggil `_apiService.deleteBook()`. Jika sukses, menampilkan `showSuccessDialog` yang kemudian memanggil `_refreshBooks()` di callback `onOk`. |
| **Navigasi Edit** | Data Flow | Pada `IconButton` Edit, fungsi `await Navigator.push` memastikan aplikasi menunggu hingga user selesai di halaman form sebelum memanggil `_refreshBooks()`. |
| **Tombol Logout** | Keamanan | Memanggil `_apiService.logout()` untuk membersihkan token dari `SharedPreferences`, memastikan user benar-benar keluar. |

### 4. Halaman Form Buku (`lib/screens/form_book_page.dart`)

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Dynamic Title** | UI/Navigasi | Judul AppBar menggunakan logika ternari (`widget.book == null ? ... : ...`) untuk menampilkan "Tambah Buku Primamart" atau "Edit Buku Primamart" secara dinamis. |
| **`initState()`** | Data Pre-fill | Menggunakan kondisi `if (widget.book != null)` untuk mengisi nilai-nilai lama buku ke dalam `TextEditingController` saat mode Edit diaktifkan. |
| **Input Parsing** | Data Integrity | Menggunakan **`int.tryParse(...) ?? 0`** pada input Harga, Jumlah, dan Volume. Ini penting untuk mencegah aplikasi *crash* jika user memasukkan karakter non-angka di kolom numerik. |
| **CRUD Logic** | Flow Control | Membandingkan apakah `widget.book` null atau tidak untuk memutuskan apakah akan memanggil `_apiService.addBook` (POST) atau `_apiService.updateBook` (PUT). |
| **Success Feedback** | Final Action | Jika sukses, menampilkan `showSuccessDialog` dengan pesan yang disesuaikan ("ditambahkan" atau "diperbarui"), lalu navigasi kembali ke `HomePage`. |

### 5. File Pendukung Utama

| File | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **`api_service.dart`** | Service Utama | Kelas yang mengisolasi semua logika HTTP. Pengecekan status code diperluas untuk menerima **200/201** pada operasi `POST/PUT` (mengatasi *false negative*). Mengelola pengiriman **Bearer Token** di setiap request terproteksi. |
| **`book.dart`** | Data Model | Model yang menjamin integritas data yang ditransfer. `fromJson` memastikan data API (misalnya `tanggal_masuk`) dipetakan ke atribut Dart. |
| **`success_dialog.dart`** | Widget Kustom | Menyediakan *popup dialog* seragam yang dapat dipanggil di berbagai halaman untuk umpan balik keberhasilan. |
| **`main.dart`** | Entry Point | Mengatur tema utama aplikasi ke warna **Coklat** dan menjalankan `LoginPage` sebagai halaman awal. |
