# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile *Full-Stack* untuk manajemen inventaris "Primamart". Aplikasi ini dikembangkan menggunakan **Flutter** (Frontend) dan **Laravel** (Backend) dengan arsitektur REST API yang aman dan skalabel menggunakan autentikasi token (Sanctum).

---

## 👤 Identitas Pengembang

| Atribut | Detail Informasi |
| :--- | :--- |
| **Nama Lengkap** | Prima Dzaky Hibatulloh |
| **NIM** | H1D023040 |
| **Shift Baru** | F |
| **Shift Asal** | B |
| **Tanggal** | 6 Desember 2025 |

---

## 🎥 Demo Aplikasi
Berikut adalah dokumentasi video yang menunjukkan alur registrasi, login, dan operasi CRUD buku:


**[https://drive.google.com/file/d/1RXtKX9JLpPH6jHPMcz02jqHhHxBUPxD7/view?usp=sharing]**


## 🔌 Spesifikasi API (Laravel Backend)
repo link = https://github.com/primadzakyhibatulloh/api_primamart
Backend menggunakan Laravel Sanctum. Semua request ke endpoint inventaris **wajib** menyertakan Header: `Authorization: Bearer <your_access_token>`

### 1. Autentikasi
| Method | Endpoint | Fungsi | Payload (JSON) | Status Sukses |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Registrasi user baru | `name`, `email`, `password` | `200 OK` / `201 Created` |
| `POST` | `/api/login` | Login & generate token | `email`, `password` | `200 OK` |
| `POST` | `/api/logout` | Hapus token aktif | - | `200 OK` |

### 2. Data Buku (CRUD)
| Method | Endpoint | Fungsi | Payload (JSON) | Status Sukses |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/books` | Ambil semua data buku | - | `200 OK` |
| `POST` | `/api/books` | Tambah buku baru | `judul`, `harga`, `jumlah`, ... | `201 Created` |
| `PUT` | `/api/books/{id}` | Edit data buku | `judul`, `harga`, `jumlah`, ... | `200 OK` |
| `DELETE` | `/api/books/{id}` | Hapus buku | - | `200 OK` |

---

## 💻 Bedah Kode & Analisis Teknis (Deep Dive Analysis)

Berikut adalah analisis mendalam mengenai logika teknis, alur data, dan implementasi kode untuk setiap komponen utama aplikasi.

### 1. Konfigurasi Dependensi (`pubspec.yaml`)
Manifestasi pustaka eksternal yang digunakan.

| Paket | Versi | Analisis Teknis |
| :--- | :--- | :--- |
| **`http`** | `^1.2.0` | Library standar untuk melakukan permintaan HTTP asinkron (`GET`, `POST`, `PUT`, `DELETE`). Lebih ringan daripada Dio untuk kebutuhan REST sederhana. |
| **`shared_preferences`** | `^2.2.2` | Penyimpanan Key-Value persisten di perangkat. Digunakan untuk menyimpan **Bearer Token** sesi login agar user tetap login meskipun aplikasi ditutup (*Session Persistence*). |

---

### 2. Layanan API (`lib/data/api_service.dart`)
Kelas *Singleton-like* yang bertindak sebagai **Facade** (Wajah) komunikasi jaringan.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`_getToken()`** | **Persistence Layer** | Mengambil token dari memori HP secara asinkron sebelum melakukan request. Jika token null, request terproteksi tidak akan dijalankan. |
| **Header Injection** | **Security Protocol** | Setiap request otomatis disisipi: <br>1. `Authorization: Bearer [token]` (Validasi Sesi). <br>2. `Accept: application/json` (Memaksa server mereturn JSON saat error, bukan HTML). |
| **Status Normalization** | **Robustness** | Menggunakan logika `if (status == 200 || status == 201)`. Ini mengatasi *False Negative* karena standar HTTP mengembalikan **201 Created** saat data baru dibuat, yang sering dianggap gagal jika kode hanya mengecek 200. |

---

### 3. Data Model (`lib/model/book.dart`)
Berfungsi sebagai **Data Transfer Object (DTO)** untuk integritas data.

| Komponen Kode | Konsep Teknis | Analisis Mendalam |
| :--- | :--- | :--- |
| **`Book.fromJson`** | **Deserialization** | *Factory Constructor* yang memetakan JSON mentah dari API menjadi Objek Dart yang aman tipe datanya (*Type Safe*). Mencegah runtime error akibat salah akses properti. |
| **`toJson()`** | **Serialization** | Kebalikan dari `fromJson`. Mengubah Objek Dart menjadi Map (JSON) yang siap dikirim melalui HTTP Body saat operasi Create/Update. |

---

### 4. Halaman Login (`lib/screens/login_page.dart`)
Gerbang autentikasi utama.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`_isLoading`** | **Race Condition Control** | Variabel state mutable. Saat `true`, tombol dikunci menjadi *spinner*. Ini mencegah user melakukan *spamming* (klik berkali-kali) yang bisa membebani server atau membuat data ganda. |
| **`pushReplacement`** | **Stack Security** | Setelah login sukses, halaman Login **dihancurkan** dari memori (*Stack*). Tombol *Back* di Android tidak akan mengembalikan user ke halaman login, melainkan menutup aplikasi. |
| **`_login()`** | **Async/Await** | Menggunakan pola `async/await` untuk menahan eksekusi UI sampai server memberikan respons, mencegah aplikasi *freeze* (ANR). |

---

### 5. Halaman Registrasi (`lib/screens/register_page.dart`)
Pendaftaran user dengan validasi ketat.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **Client Validation** | **Optimization** | Pengecekan `isEmpty` dilakukan di sisi klien. Ini menghemat *bandwidth* dengan tidak mengirim request sampah ke server. |
| **`try-catch-finally`** | **Fail-Safe** | Struktur blok kritis. Blok **`finally`** menjamin `_isLoading = false` selalu dieksekusi, mencegah UI macet (*infinite spinner*) jika terjadi error jaringan tak terduga. |
| **Callback Dialog** | **Event Driven** | `showSuccessDialog` menggunakan parameter *callback*. Navigasi `Navigator.pop` hanya dieksekusi setelah user sadar dan menekan tombol "OK". |

---

### 6. Halaman Utama (`lib/screens/home_page.dart`)
Dashboard operasional (Read & Delete).

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`FutureBuilder`** | **Async State Mgmt** | Widget ini secara otomatis mengelola 3 status koneksi: **Waiting** (Spinner), **HasError** (Pesan Error), dan **HasData** (List). Menghilangkan kebutuhan manajemen state manual yang rumit. |
| **`ListView.builder`** | **Memory Virtualization** | Menggunakan teknik *Lazy Loading*. Hanya merender item buku yang terlihat di layar. Item yang di-scroll keluar akan didaur ulang, sangat efisien RAM. |
| **`_refreshBooks()`** | **State Rehydration** | Fungsi ini melakukan *re-fetching*. Memanggil `setState` untuk me-reset variabel Future, memaksa `FutureBuilder` mengambil data terbaru dari server (Real-time feel). |
| **Delete Logic** | **Atomic Operation** | Operasi hapus melibatkan: Konfirmasi Dialog -> API Call -> Success Dialog -> Refresh Data. Urutan ini menjamin keamanan data dan UX yang baik. |

---

### 7. Halaman Form Buku (`lib/screens/form_book_page.dart`)
Polimorfisme UI (Satu halaman untuk Create & Update).

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`initState`** | **Lifecycle Hook** | Logika `if (widget.book != null)` dijalankan sekali saat widget dibuat untuk mengisi form dengan data lama (Mode Edit). |
| **`int.tryParse`** | **Defensive Prog.** | Input `TextField` adalah String, API butuh Integer. `tryParse` + `?? 0` menangani konversi dengan aman, mencegah aplikasi *crash* jika user input huruf. |
| **Dual Logic** | **Code Reusability** | Logika `if (widget.book == null)` menentukan jalur eksekusi: Panggil API **POST** (Add) atau **PUT** (Update). Mengurangi duplikasi kode hingga 50%. |

---

### 8. Entry Point (`lib/main.dart`)
Konfigurasi Global.

| Komponen Kode | Konsep Teknis | Analisis Mendalam |
| :--- | :--- | :--- |
| **`ThemeData`** | **Global Styling** | Mengatur `colorScheme` dengan `seedColor: Colors.brown`. Ini menerapkan tema warna secara konsisten ke seluruh widget (AppBar, Button, dll) tanpa perlu diatur ulang di tiap file. |
| **Initial Route** | **Navigation Root** | Menetapkan `LoginPage` sebagai halaman awal saat aplikasi di-*boot*. |

---

### 9. Widget Kustom (`lib/widget/success_dialog.dart`)
Komponen UI Reusable.

| Komponen Kode | Konsep Teknis | Analisis Mendalam |
| :--- | :--- | :--- |
| **`VoidCallback`** | **Abstraction** | Widget ini menerima fungsi sebagai parameter (`onOk`). Ini membuatnya fleksibel; halaman pemanggil bisa menentukan sendiri apa yang terjadi setelah dialog ditutup. |
| **`barrierDismissible`** | **User Guidance** | Disetel `false` agar user wajib menekan tombol "OK", memastikan pesan sukses terbaca. |

---

## 🛠️ Panduan Instalasi & Eksekusi (Step-by-Step)

### A. Konfigurasi Backend (Laravel)
1.  **Masuk Terminal**: Buka terminal di folder `responsi_backend`.
2.  **Install Vendor**: `composer install`.
3.  **Setup Database**:
    * Buat database baru di MySQL (misal: `responsi_paket3`).
    * Sesuaikan file `.env` (DB_DATABASE, DB_USERNAME, DB_PASSWORD).
4.  **Migrasi**: `php artisan migrate` (Pastikan tabel `personal_access_tokens` dibuat).
5.  **Jalankan Server**: `php artisan serve` (Server jalan di `127.0.0.1:8000`).

### B. Konfigurasi Frontend (Flutter)
1.  **Masuk Terminal**: Buka terminal baru di folder `responsi_h1d023040`.
2.  **Install Paket**: `flutter pub get`.
3.  **Cek Base URL**: Buka `lib/data/api_service.dart`, pastikan `baseUrl = 'http://127.0.0.1:8000/api'`.
4.  **Jalankan App**: `flutter run -d chrome`.
