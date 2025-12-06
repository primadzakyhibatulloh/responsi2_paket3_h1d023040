# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile *full-stack* berbasis **Flutter** yang dirancang sebagai solusi manajemen inventaris digital untuk "Primamart". Aplikasi ini menerapkan arsitektur *Client-Server* di mana Flutter bertindak sebagai Frontend yang dinamis dan **Laravel** bertindak sebagai Backend API yang aman dan *scalable*.

---

## 👤 Identitas Mahasiswa

| Atribut | Detail Informasi |
| :--- | :--- |
| **Nama Lengkap** | [ISI NAMA LENGKAP KAMU DISINI] |
| **NIM** | H1D023040 |
| **Shift Baru** | [ISI SHIFT BARU, Contoh: E] |
| **Shift Asal** | [ISI SHIFT ASAL, Contoh: A] |
| **Teknologi Stack** | Flutter (Dart), Laravel (PHP), MySQL |

---

## 🎥 Video Demo Aplikasi
Dokumentasi visual mengenai alur penggunaan aplikasi, mulai dari autentikasi hingga manajemen data CRUD:

**[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]**

*(Catatan: Pastikan video diunggah ke platform yang dapat diakses publik seperti YouTube Unlisted atau Google Drive Public)*

---

## 🔌 Spesifikasi & Arsitektur API (Backend)
Backend dibangun di atas framework **Laravel 10/11** menggunakan standar **RESTful API**. Keamanan ditangani oleh **Laravel Sanctum** yang menyediakan sistem token ringan untuk aplikasi SPA (Single Page Application) dan Mobile.

### 1. Autentikasi & Keamanan
Endpoint ini menangani siklus hidup sesi pengguna (*User Session Lifecycle*).

| Method | Endpoint | Deskripsi Teknis | Payload (Request Body) | Respons Sukses |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Membuat *resource* user baru. Melakukan validasi unik pada email dan *hashing* bcrypt pada password sebelum disimpan ke DB. | `{ "name": "...", "email": "...", "password": "..." }` | `200 OK` atau `201 Created` |
| `POST` | `/api/login` | Memeriksa kecocokan kredensial. Jika valid, server men-generate `plainTextToken` baru di tabel `personal_access_tokens`. | `{ "email": "...", "password": "..." }` | `{ "message": "Success", "access_token": "eyJh...", "token_type": "Bearer" }` |
| `POST` | `/api/logout` | Menghapus (revoke) token yang sedang digunakan dari database, memaksa klien untuk melakukan re-autentikasi untuk akses selanjutnya. | _Header: `Authorization: Bearer <token>`_ | `200 OK` |

### 2. Manajemen Inventaris (Protected Routes)
Endpoint ini dilindungi *middleware* `auth:sanctum`. Klien **wajib** menyertakan token valid di header HTTP.

| Method | Endpoint | Fungsi & Logika | Parameter Body |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/books` | Mengambil koleksi data buku. Respons dikirim dalam format JSON Array. | - |
| `POST` | `/api/books` | Menambahkan entitas buku baru. Server memvalidasi tipe data (int/string) sebelum insert. | `{ "judul": "...", "harga": 1000, "jumlah": 5, ... }` |
| `PUT` | `/api/books/{id}` | Memperbarui atribut entitas buku yang spesifik berdasarkan ID. Menggunakan metode HTTP PUT untuk penggantian data total/parsial. | `{ "judul": "...", "harga": 1000, "jumlah": 5, ... }` |
| `DELETE` | `/api/books/{id}` | Menghapus entitas buku secara permanen dari database berdasarkan ID. | - |

---

## 💻 Bedah Kode Program (Deep Dive Analysis)

Bagian ini menguraikan setiap komponen aplikasi dengan detail tingkat tinggi, mencakup alasan penggunaan widget, manajemen memori, dan alur logika.

### 1. Halaman Login (`lib/screens/login_page.dart`)
**Fungsi:** Gerbang autentikasi utama. Mengubah kredensial user menjadi token akses.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`TextEditingController`** | **Input Listener & Memory** | Controller ini bukan sekadar variabel string. Ia adalah objek yang "mendengarkan" setiap ketukan keyboard pada `TextField`. Kita mendeklarasikannya sebagai `final` agar referensinya tidak berubah di memori, namun properti `text`-nya bersifat *mutable* (bisa berubah). Ini memungkinkan kita mengambil nilai input secara instan tanpa perlu me-render ulang seluruh layar setiap kali user mengetik satu huruf. |
| **`bool _isLoading`** | **State Management & UX** | Variabel reaktif ini mencegah masalah **Double-Submit**. Saat user menekan tombol, kita set ke `true`. Ini memicu `build()` ulang yang mengubah tombol menjadi *Spinner*. Tanpa ini, user yang tidak sabar bisa menekan tombol 10x, mengirim 10 request ke server, dan menyebabkan *race condition* atau error basis data. |
| **`Navigator.pushReplacement`** | **Stack Management** | Mengapa tidak pakai `push` biasa? Karena Login adalah halaman "terminal". Setelah masuk, user tidak boleh bisa kembali ke halaman Login dengan menekan tombol *Back*. `pushReplacement` menghancurkan (*dispose*) halaman Login dari memori dan menggantinya dengan Home Page. Ini menghemat RAM dan memperbaiki alur navigasi (UX). |
| **`ScaffoldMessenger`** | **Non-Intrusive Feedback** | Kita menggunakan `SnackBar` untuk error karena sifatnya sementara (*ephemeral*). Ia muncul tanpa memblokir interaksi user (modal blocking), memberi tahu user bahwa "Password Salah" lalu menghilang otomatis, menjaga pengalaman pengguna tetap lancar. |

### 2. Halaman Registrasi (`lib/screens/register_page.dart`)
**Fungsi:** Onboarding pengguna baru dengan validasi berlapis.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **Client-Side Validation** | **Efficiency** | Kode `if (_nameController.text.isEmpty ...)` adalah lapisan pertahanan pertama. Validasi ini berjalan di HP user (*Client-side*). Tujuannya adalah mengurangi beban server. Kita tidak perlu membuang *bandwidth* internet untuk mengirim request kosong yang pasti akan ditolak server. |
| **`try-catch-finally`** | **Error Handling & Flow Control** | Struktur ini adalah standar emas stabilitas aplikasi:<br>• **Try**: Membungkus operasi berisiko (HTTP Request).<br>• **Catch**: Menangkap *Unhandled Exception* (misal: Server 500, Timeout, DNS Error). Tanpa ini, aplikasi akan *crash* dan keluar sendiri.<br>• **Finally**: Blok ini **dijamin** tereksekusi. Kita menggunakannya untuk `_isLoading = false`. Ini mencegah bug fatal di mana UI terjebak dalam status loading selamanya jika terjadi error. |
| **Callback Logic** | **Event Driven Programming** | Pada `showSuccessDialog(..., () { Navigator.pop(context); })`, kita mengirimkan sebuah *fungsi anonim* sebagai parameter. Fungsi ini tidak dijalankan saat dialog muncul, tapi **disimpan** untuk dijalankan nanti hanya ketika user menekan tombol "OK". Ini memastikan user membaca pesan sukses sebelum dialihkan. |
| **Custom Exception** | **Semantic Error** | Kita menggunakan `throw Exception('Gagal register...')` di blok `else` untuk mengubah respons API yang "valid secara HTTP" (tapi gagal secara bisnis, misal email duplikat) menjadi alur error yang bisa ditangkap oleh blok `catch`. |

### 3. Halaman Utama (`lib/screens/home_page.dart`)
**Fungsi:** Dashboard operasional. Menampilkan data (Read) dan orkestrasi aksi (Delete/Edit).

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`FutureBuilder`** | **Asynchronous UI Rendering** | Widget ini adalah jembatan antara dunia *Synchronous* (UI Flutter) dan *Asynchronous* (Data API). Ia secara otomatis berlangganan ke sebuah `Future`.<br>• Saat data sedang "di jalan" (*network latency*), ia merender `ConnectionState.waiting`.<br>• Saat data sampai, ia merender `ConnectionState.done` dengan data.<br>• Ini menghilangkan kebutuhan kita untuk membuat variabel manual `bool isDataLoaded`. |
| **`ListView.builder`** | **Memory Optimization** | Bayangkan jika ada 10.000 buku. `ListView` biasa akan merender 10.000 widget sekaligus, memakan habis RAM HP. `ListView.builder` menggunakan teknik **Lazy Loading** (Virtualisasi). Ia hanya membuat widget untuk buku yang sedang tampil di layar + sedikit *buffer*. Saat di-scroll, widget yang keluar layar dihancurkan, dan widget baru dibuat. |
| **`_refreshBooks()`** | **State Hydration** | Fungsi ini melakukan teknik *re-fetching*. Kita memanggil `setState` bukan untuk mengubah nilai variabel semata, tapi untuk memicu `build()` ulang pada widget tree. Karena `Future` di-assign ulang, `FutureBuilder` akan restart proses pengambilan datanya, memberikan efek "Refresh" data tanpa perlu reload aplikasi. |
| **Object Passing** | **Data Propagation** | Saat navigasi ke Edit Page: `FormBookPage(book: snapshot.data![index])`. Kita mengirimkan seluruh objek buku lewat konstruktor. Ini disebut *Dependency Injection* sederhana. Halaman tujuan tidak perlu request ulang ke server untuk tahu detail buku yang mau diedit, karena datanya sudah dikirim dari Home. Efisien dan cepat. |

### 4. Halaman Form Buku (`lib/screens/form_book_page.dart`)
**Fungsi:** Polimorfisme UI. Satu layar menangani dua operasi logika berbeda (Create & Update).

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`initState` logic** | **Widget Lifecycle Hook** | `initState` adalah metode pertama yang jalan saat widget dibuat. Kita menaruh logika pengisian form (`_judulCtrl.text = ...`) di sini, bukan di `build`. Kenapa? Karena `build` bisa dipanggil berkali-kali (misal saat keyboard muncul/tutup), kita tidak mau teks yang baru diketik user tertimpa kembali oleh data lama setiap kali layar berkedip. |
| **Ternary Operator** | **Conditional Rendering** | `widget.book == null ? "Tambah" : "Edit"`. Satu baris kode ini mengubah seluruh konteks halaman. Kita memeriksa apakah ada data buku yang dikirim. Jika `null`, aplikasi berasumsi ini mode "Tambah Baru". Jika ada objek, aplikasi masuk mode "Revisi". |
| **`int.tryParse`** | **Defensive Programming** | Inputan `TextField` selalu String. API butuh Integer. Konversi langsung (`int.parse`) sangat berbahaya karena akan *throw error* jika user memasukkan huruf. `int.tryParse` adalah metode aman yang mengembalikan `null` jika gagal, yang kemudian kita tangani dengan operator *coalescing* (`?? 0`) untuk memberikan nilai default aman. |
| **Abstraction Logic** | **Code Maintainability** | Tombol simpan memanggil `_submit`. Fungsi ini adalah otak yang memutuskan jalur mana yang diambil. Penggunaan satu form untuk dua fungsi (Add/Edit) mengurangi duplikasi kode secara signifikan (*Don't Repeat Yourself / DRY Principle*), membuat aplikasi lebih mudah dirawat di masa depan. |

### 5. Lapisan Data & Utilitas (`lib/data/` & `lib/widget/`)

| File / Komponen | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`api_service.dart`** | **Encapsulation & Singleton Idea** | Kelas ini bertindak sebagai **Facade** (wajah) bagi seluruh operasi jaringan. <br>1. **Header Injection**: Secara otomatis menyisipkan `Authorization: Bearer xyz` dari penyimpanan lokal. Ini mengamankan endpoint.<br>2. **MIME Type Handling**: Header `Accept: application/json` memaksa Laravel mengembalikan error dalam format JSON yang bisa dibaca mesin, bukan HTML.<br>3. **Status Code Normalization**: Logika `if (status == 200 || status == 201)` adalah penanganan cerdas untuk standar HTTP RESTful, di mana *Create Success* biasanya 201, bukan 200. |
| **`book.dart`** | **JSON Serialization** | Dart adalah bahasa *Strongly Typed*. API mengirim JSON (*weakly typed map*). Kelas Model ini adalah penerjemah.<br>• `fromJson`: Mencegah error runtime dengan memvalidasi struktur data saat masuk.<br>• `toJson`: Memastikan data yang dikirim ke server memiliki nama key yang tepat (`"tanggal_masuk"`, bukan `"tglMasuk"`), sesuai ekspektasi database. |
| **`success_dialog.dart`** | **Component Reusability** | Daripada menulis kode `showDialog` yang panjang (20+ baris) di 4 tempat berbeda (Register, Add, Edit, Delete), kita membungkusnya dalam satu fungsi. Ini membuat kode di halaman utama jauh lebih bersih (*Clean Code*) dan menjamin konsistensi desain UI di seluruh aplikasi. |
| **`main.dart`** | **Dependency Root** | Titik awal eksekusi. Di sini kita mendefinisikan `ThemeData` global. Mengubah warna di sini (`seedColor: Colors.brown`) akan secara otomatis mengubah warna semua AppBar, Button, dan indikator di seluruh aplikasi, menunjukkan kekuatan sistem tema Flutter. |

---

## 🛠️ Panduan Instalasi & Eksekusi (Langkah Demi Langkah)

Ikuti instruksi ini dengan teliti untuk menyiapkan lingkungan pengembangan lokal.

### Tahap 1: Konfigurasi Backend (Laravel)
Backend bertugas menyediakan API dan database.

1.  **Navigasi Terminal**: Buka terminal/CMD dan masuk ke direktori project Laravel.
2.  **Instalasi Pustaka**: Jalankan `composer install` untuk mengunduh dependensi PHP.
3.  **Setup Environment**:
    * Copy file `.env.example` menjadi `.env`.
    * Atur konfigurasi database: `DB_DATABASE=responsi_paket3`.
4.  **Database Migration**:
    * Jalankan `php artisan migrate`. Perintah ini akan membuat tabel `users`, `books`, dan `personal_access_tokens` di database MySQL Anda.
5.  **Running Server**:
    * Jalankan `php artisan serve`.
    * Server akan aktif di `http://127.0.0.1:8000`. **Jangan tutup terminal ini.**

### Tahap 2: Konfigurasi Frontend (Flutter)
Frontend adalah aplikasi antarmuka pengguna.

1.  **Navigasi Terminal**: Buka terminal baru dan masuk ke direktori project Flutter.
2.  **Instalasi Pustaka**: Jalankan `flutter pub get`. Perintah ini membaca `pubspec.yaml` dan mengunduh paket `http` dan `shared_preferences`.
3.  **Verifikasi Koneksi**:
    * Pastikan `baseUrl` di `lib/data/api_service.dart` bernilai `http://127.0.0.1:8000/api` (untuk Chrome) atau `http://10.0.2.2:8000/api` (untuk Emulator Android).
4.  **Running Aplikasi**:
    * Jalankan `flutter run -d chrome`.
    * Chrome akan terbuka dan menampilkan Halaman Login.

---
*Dokumen ini disusun sebagai bagian dari persyaratan tugas Responsi Praktikum Pemrograman Mobile, mencakup aspek fungsionalitas, keamanan, dan kualitas kode.*
