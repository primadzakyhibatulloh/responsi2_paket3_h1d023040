# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile berbasis **Flutter** (Frontend) yang dirancang untuk manajemen inventaris barang di supermarket "Primamart". Aplikasi ini terintegrasi penuh dengan **Laravel** (Backend) melalui RESTful API yang aman menggunakan autentikasi token (Laravel Sanctum).

---

## 👤 Identitas Mahasiswa

| Atribut | Detail Informasi |
| :--- | :--- |
| **Nama Lengkap** | [ISI NAMA LENGKAP KAMU DISINI] |
| **NIM** | H1D023040 |
| **Shift Baru** | [ISI SHIFT BARU, Contoh: E] |
| **Shift Asal** | [ISI SHIFT ASAL, Contoh: A] |
| **Tanggal Pengerjaan** | Desember 2025 |

---

## 🎥 Video Demo Aplikasi
Berikut adalah bukti demonstrasi fungsionalitas aplikasi mulai dari Register, Login, CRUD, hingga Logout:

**[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]**

*(Instruksi: Rekam layar HP/Emulator, upload ke Google Drive/YouTube, pastikan akses disetel ke 'Public/Anyone with link', lalu tempel link-nya di atas)*

---

## 🔌 Spesifikasi Teknis API (Backend Laravel)
Aplikasi ini berkomunikasi dengan server menggunakan protokol HTTP standar. Keamanan dijamin menggunakan **Bearer Token** yang dihasilkan oleh Laravel Sanctum.

### 1. Autentikasi Pengguna
Endpoint ini bersifat publik (tidak butuh token) dan digunakan untuk mendapatkan akses masuk.

| Method | Endpoint | Deskripsi Fungsi | Parameter Body (Raw JSON) | Respons Sukses |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Mendaftarkan pengguna baru ke dalam tabel `users`. Melakukan hashing password otomatis. | `name` (string), `email` (string), `password` (string, min 8 char) | `200 OK` / `201 Created` |
| `POST` | `/api/login` | Memvalidasi kredensial. Jika cocok, server mengembalikan string acak (`access_token`) untuk sesi tersebut. | `email` (string), `password` (string) | `200 OK` + `{ access_token: "..." }` |
| `POST` | `/api/logout` | Menghanguskan token yang sedang dipakai sehingga tidak bisa digunakan lagi. | _(Header Authorization Wajib)_ | `200 OK` |

### 2. Manajemen Inventaris (CRUD Buku)
Seluruh endpoint ini dilindungi oleh middleware `auth:sanctum`. Request wajib menyertakan Header: `Authorization: Bearer <token_anda>`.

| Method | Endpoint | Deskripsi Fungsi | Parameter Body (Raw JSON) |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/books` | Mengambil seluruh baris data dari tabel `books`. Respons berupa array of objects. | - |
| `POST` | `/api/books` | Menyisipkan (Insert) satu baris data baru ke tabel `books`. | `judul`, `harga`, `jumlah`, `tanggal_masuk`, `volume`, `penulis`, `penerbit` |
| `PUT` | `/api/books/{id}` | Memperbarui (Update) data buku yang sudah ada berdasarkan Primary Key (ID). | `judul`, `harga`, `jumlah`, `tanggal_masuk`, `volume`, `penulis`, `penerbit` |
| `DELETE` | `/api/books/{id}` | Menghapus (Soft/Hard Delete) satu baris data buku berdasarkan Primary Key (ID). | - |

---

## 💻 Bedah Kode Program (Deep Dive Explanation)

Berikut adalah analisis mendalam mengenai arsitektur, logika, dan implementasi teknis dari setiap komponen dalam aplikasi Flutter ini.

### 1. 🔐 Halaman Login (`lib/screens/login_page.dart`)
Berfungsi sebagai gerbang keamanan. File ini mengelola sesi awal pengguna.

| Komponen / Kode | Konsep Teknis | Penjelasan Mendalam & Alur Logika |
| :--- | :--- | :--- |
| **`TextEditingController`** | Input Handling | Variabel `_emailController` dan `_passwordController` bertindak sebagai pendengar (*listeners*) pada kolom input. Tidak seperti variabel string biasa, controller ini membiarkan kita memanipulasi teks dari kode (misal: menghapusnya setelah login gagal) dan mengambil nilainya secara real-time tanpa me-render ulang UI. |
| **`bool _isLoading`** | State Management | Variabel boolean sederhana namun krusial. Saat bernilai `true`, ia mengubah tampilan tombol "Masuk" menjadi putaran loading (*spinner*). Ini mencegah **Race Condition** di mana pengguna bisa menekan tombol berkali-kali dan mengirim request ganda ke server yang bisa menyebabkan error atau beban server berlebih. |
| **`_login()` Method** | Asynchronous Logic | Fungsi ini ditandai dengan `async` karena operasi jaringan (HTTP) membutuhkan waktu dan tidak boleh memblokir *Main Thread* (UI). Penggunaan `await _apiService.login(...)` memerintahkan aplikasi untuk "tunggu di baris ini sampai server membalas", baru kemudian lanjut ke baris berikutnya. |
| **`Navigator.pushReplacement`** | Stack Navigation | Ketika login sukses, kita tidak menggunakan `push` biasa, melainkan `pushReplacement`. **Alasannya:** Ini menghapus halaman Login dari tumpukan memori (*stack*). Jadi, ketika user berada di Home Page dan menekan tombol "Back" pada Android, aplikasi akan keluar, BUKAN kembali ke halaman Login. Ini adalah praktik keamanan standar. |
| **`ScaffoldMessenger`** | User Feedback | Jika login gagal (return `false`), kita menggunakan `SnackBar` untuk memberi tahu user. Pesan ini muncul sementara di bagian bawah layar, memberikan umpan balik yang tidak mengganggu namun jelas. |

### 2. 📝 Halaman Registrasi (`lib/screens/register_page.dart`)
Menangani pembuatan akun dengan validasi ketat dan penanganan kesalahan jaringan.

| Komponen / Kode | Konsep Teknis | Penjelasan Mendalam & Alur Logika |
| :--- | :--- | :--- |
| **Client-Side Validation** | Data Integrity | Sebelum memanggil API, kode melakukan pengecekan `isEmpty` pada nama, email, dan password. **Tujuannya:** Menghemat *bandwidth* dan mempercepat respons. Tidak perlu mengirim data ke server jika kita sudah tahu data itu tidak lengkap dari sisi aplikasi. |
| **Blok `try-catch-finally`** | Robustness (Ketahanan) | Struktur kode ini menjamin aplikasi tidak *crash* (force close):<br>• **Try:** Menjalankan request berisiko (koneksi internet).<br>• **Catch:** Menangkap error spesifik (misal: 422 Unprocessable Entity atau Timeout) dan menampilkannya.<br>• **Finally:** Blok ini **dijamin tereksekusi** di akhir. Kita menggunakannya untuk `_isLoading = false`. Ini mencegah bug "Spinner Stuck" (loading berputar selamanya) jika terjadi error di tengah jalan. |
| **`showSuccessDialog`** | Modular UI | Kita memanggil widget dialog eksternal. Di sini terdapat logika *Callback*: `() { Navigator.pop(context); }`. Artinya, navigasi kembali ke halaman Login hanya akan dieksekusi **SETELAH** pengguna secara sadar menekan tombol "OK" pada popup sukses. |
| **Explicit Exception** | Flow Control | Pada logika `if (success) ... else { throw Exception(...) }`, kita secara manual memicu error jika API mengembalikan `false` (misal email duplikat). Ini agar alur program melompat ke blok `catch` dan pesan error bisa ditampilkan seragam di SnackBar. |

### 3. 🏠 Halaman Utama Dashboard (`lib/screens/home_page.dart`)
Pusat aktivitas aplikasi. Menampilkan data (Read) dan memicu aksi Hapus/Logout.

| Komponen / Kode | Konsep Teknis | Penjelasan Mendalam & Alur Logika |
| :--- | :--- | :--- |
| **`FutureBuilder`** | Async Rendering | Widget ini adalah solusi elegan Flutter untuk data asinkron. Ia memantau status `Future` (request API) dan secara otomatis merender UI yang berbeda berdasarkan 3 fase:<br>1. **ConnectionState.waiting**: Menampilkan `CircularProgressIndicator`.<br>2. **HasError**: Menampilkan pesan error.<br>3. **HasData**: Menampilkan `ListView` berisi data buku. Tanpa widget ini, kita harus mengelola 3 variabel boolean manual untuk loading/error/sukses. |
| **`_refreshBooks()`** | Reactive State | Fungsi ini melakukan teknik *State Re-assignment*. Dengan memanggil `setState(() { _books = getBooks(); })`, kita memberi tahu Flutter bahwa sumber data telah berubah. Flutter kemudian membuang tampilan lama dan menjalankan ulang `FutureBuilder` untuk mengambil data terbaru dari server (Real-time update simulation). |
| **`ListView.builder`** | Performance Optimization | Alih-alih merender 1000 buku sekaligus (yang bikin HP lag), `ListView.builder` menggunakan teknik **Lazy Loading**. Ia hanya merender widget buku yang sedang terlihat di layar HP. Saat user scroll ke bawah, widget lama dibuang dan widget baru dibuat. Sangat efisien memori. |
| **`showDialog` (Await)** | Synchronous UI Blocking | Pada tombol Hapus, kita menggunakan `await showDialog(...)`. Kode di bawahnya tidak akan jalan sampai user memilih "Ya" atau "Tidak". Jika user memilih "Ya" (`true`), barulah fungsi `deleteBook` dipanggil. Ini mencegah ketidaksengajaan hapus data (*accidental deletion*). |
| **Data Passing** | Navigation Arguments | Saat menekan tombol Edit, kita melakukan `Navigator.push(..., FormBookPage(book: currentBook))`. Kita "melempar" objek buku yang sedang diklik ke halaman sebelah. Ini memungkinkan halaman Form tahu persis buku mana yang harus diedit tanpa perlu request ulang ke server. |

### 4. ✏️ Halaman Form Buku (`lib/screens/form_book_page.dart`)
Halaman cerdas yang memiliki kepribadian ganda: Bisa jadi "Form Tambah" atau "Form Edit" (Polimorfisme UI).

| Komponen / Kode | Konsep Teknis | Penjelasan Mendalam & Alur Logika |
| :--- | :--- | :--- |
| **`initState` Pre-filling** | Widget Lifecycle | Metode `initState` dijalankan paling awal sebelum UI digambar. Di sini kita mengecek `if (widget.book != null)`. Jika ada data buku (mode Edit), kita mengisi `text` pada controller. Hasilnya: Saat halaman muncul, form sudah terisi data lama, siap diedit user. |
| **`int.tryParse(...) ?? 0`** | Type Safety | API Laravel mewajibkan field harga/jumlah/volume bertipe Integer. Namun, `TextField` Flutter menghasilkan String. Fungsi `tryParse` mencoba mengubah String ke Int. Jika gagal (misal user input huruf "abc"), ia mengembalikan `null`. Operator `?? 0` (Null Coalescing) kemudian mengubah `null` menjadi `0`. Ini teknik defensif untuk mencegah aplikasi *crash* akibat kesalahan input tipe data. |
| **Dual Logic Submit** | Code Reusability | Tombol Simpan hanya memanggil satu fungsi `_submit`. Di dalamnya terdapat percabangan:<br>• Jika `widget.book` kosong -> Panggil `api.addBook` (POST).<br>• Jika `widget.book` ada -> Panggil `api.updateBook` (PUT).<br>Teknik ini menghemat penulisan kode hingga 50% karena kita tidak perlu membuat dua file halaman terpisah untuk Tambah dan Edit. |
| **Feedback Loop** | User Experience | Setelah data berhasil disimpan/diupdate, aplikasi tidak diam saja. Ia memunculkan Popup Sukses. Setelah user klik OK, `Navigator.pop` dipanggil untuk membuang halaman Form dan kembali ke Home, di mana Home akan otomatis me-refresh list datanya. |

### 5. 🌐 Layanan API & Utilitas (`lib/data/` & `lib/widget/`)

| File / Kode | Kategori | Penjelasan Mendalam & Alur Logika |
| :--- | :--- | :--- |
| **`api_service.dart`** | **Centralized Networking** | • **Singleton Pattern Idea**: Kelas ini mengisolasi seluruh urusan HTTP. Halaman UI tidak boleh tahu menahu soal URL atau JSON parsing.<br>• **Header Injection**: Setiap request CRUD otomatis disisipi `Authorization: Bearer [token]`. Token ini diambil dari penyimpanan lokal HP.<br>• **MIME Type**: Header `Accept: application/json` dipasang agar jika Laravel error, ia membalas dengan JSON yang bisa dibaca aplikasi, bukan halaman HTML error (Whoops page).<br>• **Status Code Handling**: Kode secara eksplisit menganggap **200 (OK)** dan **201 (Created)** sebagai sukses. Ini penting karena secara default standar HTTP mengembalikan 201 saat data baru dibuat. |
| **`book.dart`** | **Data Transfer Object (DTO)** | • **Serialization (`toJson`)**: Mengubah Objek Dart (yang ada di memori RAM) menjadi format string JSON agar bisa dikirim lewat internet.<br>• **Deserialization (`fromJson`)**: Mengambil data mentah dari server (JSON) dan memasukkannya ke dalam wadah Objek Dart yang terstruktur. Ini memungkinkan kita mengakses data dengan cara `book.judul` alih-alih `json['judul']`, mengurangi risiko *typo* dan error tipe data. |
| **`success_dialog.dart`** | **Modular Widget** | Widget ini dibuat terpisah agar desain popup "Berhasil" konsisten di seluruh aplikasi (warna coklat, ikon centang). Ia menerima parameter `VoidCallback onOk`, yang memungkinkan halaman pemanggil (Caller) menentukan sendiri apa yang harus dilakukan setelah dialog ditutup (misal: Halaman Login ingin navigasi, tapi Halaman Home hanya ingin refresh list). |
| **`main.dart`** | **App Config** | • **ThemeData**: Mengatur warna primer (`seedColor`) menjadi Coklat. Ini mengubah warna default AppBar, Button, dan FloatingActionButton di seluruh aplikasi secara global.<br>• **Routing**: Menetapkan `LoginPage` sebagai halaman pertama yang dimuat saat aplikasi dibuka. |

---

## 🛠️ Panduan Instalasi & Eksekusi

Ikuti langkah-langkah berikut secara berurutan untuk menjalankan proyek ini di lingkungan lokal Anda.

### Tahap 1: Backend (Laravel)
1.  Buka terminal/CMD, arahkan ke folder project backend.
2.  Install dependensi (jika belum): `composer install`.
3.  Siapkan database MySQL (buat database baru di phpMyAdmin).
4.  Setting file `.env` sesuai nama database.
5.  Jalankan migrasi tabel: `php artisan migrate`.
6.  Jalankan server lokal: `php artisan serve`.
    * *Catatan: Server akan berjalan di `http://127.0.0.1:8000`. Jangan tutup terminal ini.*

### Tahap 2: Frontend (Flutter)
1.  Buka terminal baru, arahkan ke folder project flutter.
2.  Download pustaka yang dibutuhkan: `flutter pub get`.
3.  Pastikan konfigurasi `api_service.dart` mengarah ke URL yang benar (`http://127.0.0.1:8000/api` untuk Chrome).
4.  Jalankan aplikasi: `flutter run -d chrome`.

---
*Dibuat untuk memenuhi tugas Responsi Praktikum Pemrograman Mobile 2025.*
