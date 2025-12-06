# Responsi 2 Mobile Paket 3 - Inventaris Primamart (Dokumentasi Teknis Ekstrem)

Aplikasi mobile *Full-Stack* untuk manajemen inventaris "Primamart". Aplikasi ini dikembangkan menggunakan **Flutter** (Frontend) dan **Laravel** (Backend) dengan arsitektur REST API, menerapkan prinsip *Separation of Concerns* (Pemisahan Tanggung Jawab) yang ketat.

---

## 👤 Identitas Pengembang & Arsitektur Proyek

| Atribut | Detail Informasi | Keterangan Teknis |
| :--- | :--- | :--- |
| **Nama Lengkap** | [ISI NAMA LENGKAP KAMU DISINI] | **NIM**: H1D023040 |
| **Shift** | [ISI SHIFT BARU] / [ISI SHIFT ASAL] | Proyek **Responsi** mata kuliah Pemrograman Mobile. |
| **Arsitektur Flutter** | Layered Architecture (Screen, Service, Model) | UI berinteraksi hanya dengan Service; Model menjamin integritas data (DTO Pattern). |
| **Backend Framework** | Laravel 10/11 (PHP) | Digunakan untuk menyediakan endpoint API yang *stateless* dan aman (Sanctum). |

---

## 🎥 Video Demo Aplikasi
Bukti fungsionalitas penuh: **[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]**

---

## 🔌 Spesifikasi Teknis API (Backend Laravel)
Semua komunikasi dilakukan melalui JSON. Endpoint inventaris membutuhkan `Authorization: Bearer <token>`.

### 1. Autentikasi & Respons Kode HTTP
| Method | Endpoint | Fungsi Klien | Status Code | Deskripsi Teknis |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Membuat User | 200/201 | Sukses; User dibuat. |
| | | | 422 | Gagal Validasi (Contoh: Email sudah terdaftar, Password kurang panjang). |
| `POST` | `/api/login` | Memulai Sesi | 200 | Sukses; Token dikirimkan untuk sesi berikutnya. |
| | | | 401 | Unauthorized; Kredensial (Email/Password) salah. |
| `POST` | `/api/logout` | Mengakhiri Sesi | 200 | Token berhasil dicabut (*revoked*) dari tabel `personal_access_tokens`. |

### 2. Manajemen Inventaris (CRUD Buku)
| Method | Endpoint | Fungsi | Data Wajib Kirim | Status Sukses |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/books` | Read All | - | 200 OK |
| `POST` | `/api/books` | Create New | `judul`, `harga`, `jumlah`, `tanggal_masuk`, `volume`, `penulis`, `penerbit` | 201 Created / 200 OK |
| `DELETE` | `/api/books/{id}` | Delete by ID | - | 200 OK |

---

## 💻 Bedah Kode Program (Analisis Teknik 5X Lipat)

### 1. Lapisan Layanan Data (`lib/data/api_service.dart`)
Kelas ini adalah jantung komunikasi. Bertanggung jawab atas semua I/O jaringan dan keamanan.

| Komponen Kode | Konsep Teknis | Analisis Mendalam (Bagian dari `ApiService`) |
| :--- | :--- | :--- |
| **`baseUrl`** | **Deployment Strategy** | Disetel ke `http://127.0.0.1:8000` (Localhost/Chrome) atau `http://10.0.2.2:8000` (Android Emulator). Perubahan ini harus dilakukan manual untuk menyesuaikan lingkungan *deployment* lokal. |
| **`_getToken()`** | **State Persistence** | Mengakses `SharedPreferences` untuk mengambil Bearer Token. Token ini menjamin *state* login dipertahankan meskipun aplikasi ditutup dan dibuka kembali. Ini adalah fondasi keamanan *Stateless API*. |
| **Headers** | **HTTP Protocol** | Setiap request menyertakan header `Accept: application/json` (memberi tahu server bahwa klien hanya menerima JSON) dan `Authorization: Bearer [token]`. Ini mencegah masalah *Content Negotiation* dan memvalidasi akses. |
| **`register()`/`addBook()`** | **Status Code Robustness** | Logika pengecekan sukses adalah `return response.statusCode == 200 || response.statusCode == 201;`. Ini mengatasi *False Negative* yang terjadi saat Laravel mengembalikan kode **201 (Created)**, yang secara teknis sukses, namun tidak sama dengan 200. |
| **`await http.post(...)`** | **Asynchronous I/O** | Penggunaan `await` sangat penting. Operasi HTTP adalah I/O-bound dan lambat. `await` mencegah *blocking* pada *Main Thread* Flutter, menjaga *frame rate* (FPS) tetap tinggi dan UI responsif. |

### 2. Halaman Login (`lib/screens/login_page.dart`)
Mengelola state UI kritis saat autentikasi.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`TextEditingController`** | **State Management Lokal** | Objek ini adalah satu-satunya cara yang efisien bagi Flutter untuk membaca perubahan input tanpa harus membuat `TextField` menjadi reaktif sepenuhnya. Mereka menyimpan *state* kursor, posisi teks, dan nilai input. |
| **`_login()` Method** | **State Flow Control** | Fungsi ini dimulai dengan `setState({_isLoading: true})` dan diakhiri dengan `setState({_isLoading: false})`. Ini adalah siklus state *Loading* yang harus selalu lengkap untuk mencegah *UI Freeze* dan memastikan pengalaman pengguna yang baik. |
| **`Navigator.pushReplacement`** | **Navigasi Stack** | Digunakan untuk mengganti halaman. Ini membuang `LoginPage` dari memori (*Stack Pop*), sehingga tombol *back* pengguna tidak akan pernah membawa mereka kembali ke halaman login, meningkatkan keamanan dan kebersihan navigasi. |
| **Error Feedback** | **UX Handling** | Saat gagal, menggunakan `ScaffoldMessenger.of(context).showSnackBar`. Karena login adalah proses tunggal, feedback harus cepat dan jelas tanpa memblokir layar (non-modal). |

### 3. Halaman Registrasi (`lib/screens/register_page.dart`)
Mengutamakan stabilitas dan *input integrity*.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`try-catch-finally`** | **Exception Handling** | Ini adalah *fail-safe* kritis. Jika koneksi terputus saat respons balik (API sukses insert, tapi koneksi putus), blok `catch` akan menangkap error, tetapi blok **`finally`** tetap memastikan `_isLoading` disetel ke `false`. Tanpa `finally`, spinner akan berputar selamanya. |
| **Client-Side Validation** | **Optimasi Jaringan** | Pengecekan `if (_nameController.text.isEmpty)` dilakukan di HP. Ini memotong request yang sudah pasti gagal (misal, user lupa mengisi nama) sehingga tidak membuang *data usage* user dan *processing power* server. |
| **`showSuccessDialog`** | **Callback Pattern** | Dialog sukses menggunakan parameter *VoidCallback*. Aksi navigasi (`Navigator.pop(context)`) disematkan di dalam *callback* ini. Artinya, navigasi hanya terjadi **setelah** user menutup popup, menjamin pesan sukses terbaca. |

### 4. Halaman Utama (`lib/screens/home_page.dart`)
Mengimplementasikan fitur *Read* dan *Delete* dengan efisiensi memori.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`FutureBuilder`** | **Asynchronous State** | Widget ini adalah mesin untuk data asinkron. Ia memantau status `Future<List<Book>>` secara pasif. Logika `if (snapshot.connectionState == ConnectionState.waiting)` memastikan UI menampilkan *loading* yang tepat di waktu yang tepat, mencegah *bug* "data tiba-tiba muncul" atau layar kosong. |
| **`ListView.builder`** | **Performance: Lazy Loading** | Karena daftar inventaris bisa sangat panjang, `builder` memastikan hanya item yang sedang terlihat di layar (*Viewport*) yang di-render. Widget lain "dimatikan" atau belum dibuat. Ini menjaga penggunaan RAM tetap rendah dan aplikasi berjalan 60 FPS. |
| **`_refreshBooks()`** | **Rehydration** | Fungsi ini memaksa `FutureBuilder` untuk menjalankan ulang `future` dan mengambil data baru dari API. Ini dipanggil setiap kali terjadi perubahan data (setelah Create, Update, atau Delete) untuk menjaga konsistensi data antara server dan tampilan klien. |
| **Aksi Delete** | **Safety & UX** | Aksi Delete melibatkan dua dialog: (1) `showDialog` untuk **konfirmasi** (mencegah hapus tidak sengaja), dan (2) `showSuccessDialog` (sebagai umpan balik). Kode `await showDialog` memastikan proses API hanya dimulai setelah persetujuan user. |

### 5. Lapisan Model & Service (`lib/model/book.dart` & `lib/data/api_service.dart`)
Fondasi struktural dan keamanan data.

| Komponen Kode | Konsep & Alasan Teknis | Analisis Mendalam & Implementasi Teknis |
| :--- | :--- | :--- |
| **`book.dart`** | **Serialization / DTO** | Kelas ini adalah **Data Transfer Object (DTO)**. Ia menjamin data yang masuk dan keluar memiliki struktur yang konsisten. <br>• **`factory Book.fromJson`**: Mengubah JSON mentah API menjadi Objek Dart yang terstruktur. <br>• **`Map<String, dynamic> toJson()`**: Menyiapkan Objek Dart untuk dikirim kembali, memastikan *key names* JSON cocok dengan ekspektasi Laravel (misalnya `tanggal_masuk`). |
| **`api_service.dart`** | **Protokol & Keamanan** | Kelas ini adalah *proxy* ke server. Semua metode HTTP-nya disetel untuk mengirimkan `Authorization: Bearer [token]` dan menerima respons yang sesuai. Penanganan status code 201 untuk operasi Create adalah contoh *robustness* agar aplikasi tidak gagal saat berhadapan dengan standar REST yang ketat. |

---

## 🛠️ Panduan Instalasi & Eksekusi

### Tahap 1: Konfigurasi Backend (Laravel)
1.  **Navigasi Terminal**: Masuk ke direktori project Laravel.
2.  **Database Migration**: `php artisan migrate` (Pastikan semua tabel terbuat, termasuk `personal_access_tokens`).
3.  **Running Server**: `php artisan serve`.
    * *Catatan: Server akan aktif di `http://127.0.0.1:8000`.*

### Tahap 2: Konfigurasi Frontend (Flutter)
1.  **Navigasi Terminal**: Masuk ke direktori project Flutter.
2.  **Verifikasi Koneksi**: Pastikan `baseUrl` di `lib/data/api_service.dart` sudah benar (`http://127.0.0.1:8000/api`).
3.  **Running Aplikasi**: `flutter run -d chrome`.
