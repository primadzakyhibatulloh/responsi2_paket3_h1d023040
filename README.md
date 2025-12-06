# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile *Full-Stack* untuk manajemen inventaris "Primamart". Aplikasi ini dikembangkan menggunakan **Flutter** (Frontend) dan **Laravel** (Backend) dengan arsitektur REST API dan autentikasi token (Sanctum).

---

## 👤 Identitas Pengembang

| Atribut | Detail Informasi |
| :--- | :--- |
| **Nama Lengkap** | [ISI NAMA LENGKAP KAMU DISINI] |
| **NIM** | H1D023040 |
| **Shift Baru** | [ISI SHIFT BARU, Contoh: E] |
| **Shift Asal** | [ISI SHIFT ASAL, Contoh: A] |
| **Tanggal** | Desember 2025 |

---

## 🎥 Demo Aplikasi
Berikut adalah dokumentasi video yang menunjukkan alur registrasi, login, dan operasi CRUD buku:

**[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]**

*(Catatan: Pastikan video diunggah ke platform yang dapat diakses publik)*

---

## 🔌 Spesifikasi API (Laravel Backend)
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

## 💻 Bedah Kode & Analisis Teknis (Deep Dive)

### 1. Halaman Login (`lib/screens/login_page.dart`)
Berfungsi sebagai gerbang autentikasi utama.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`TextEditingController`** | **Input Listener** | Objek ini "mendengarkan" input keyboard pada `TextField` secara real-time tanpa perlu me-render ulang seluruh widget. Memungkinkan pengambilan nilai (`.text`) saat tombol ditekan. |
| **`bool _isLoading`** | **State Management** | Mencegah **Race Condition**. Saat bernilai `true`, tombol berubah menjadi *spinner* dan interaksi dikunci. Ini mencegah user menekan tombol berkali-kali saat request sedang berjalan. |
| **`_login()` Method** | **Async Logic** | Fungsi berjalan secara *asynchronous* (`async/await`). UI ditahan di fase loading sampai server memberikan respons, mencegah aplikasi *freeze* (ANR). |
| **`pushReplacement`** | **Stack Security** | Mengganti halaman Login dengan Home Page secara destruktif. Halaman Login dihapus dari memori (*stack*), sehingga tombol *Back* di Android akan menutup aplikasi, bukan kembali ke login (Keamanan Sesi). |

### 2. Halaman Registrasi (`lib/screens/register_page.dart`)
Menangani pendaftaran user dengan validasi ketat.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **Validasi Client-Side** | **Efficiency** | Pengecekan `if (isEmpty)` dilakukan sebelum request dikirim. Ini menghemat *bandwidth* dan beban server dengan menolak data kosong di sisi aplikasi. |
| **`try-catch-finally`** | **Robustness** | Struktur *fail-safe* utama. <br>• **Try**: Menjalankan request berisiko.<br>• **Catch**: Menangkap error (Server 500, Timeout).<br>• **Finally**: Menjamin `_isLoading = false` tereksekusi apa pun yang terjadi, mencegah *infinite spinner*. |
| **Callback Dialog** | **Event Driven** | `showSuccessDialog` menggunakan parameter *callback*. Navigasi `Navigator.pop` hanya dieksekusi **SETELAH** user menekan tombol "OK" pada popup, memastikan pesan sukses terbaca. |
| **Custom Exception** | **Flow Control** | Menggunakan `throw Exception` manual jika API mengembalikan `false` (misal email duplikat) agar alur program melompat ke blok `catch` untuk penanganan error yang seragam. |

### 3. Halaman Utama (`lib/screens/home_page.dart`)
Dashboard untuk melihat (Read) dan menghapus (Delete) data.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`FutureBuilder`** | **Async UI** | Widget ini mengotomatisasi manajemen status UI (`waiting`, `hasData`, `hasError`). Menghilangkan kebutuhan penulisan logika *if-else* manual yang rumit untuk status loading data. |
| **`ListView.builder`** | **Memory Opt.** | Menggunakan teknik **Virtualisasi/Lazy Loading**. Hanya merender widget buku yang terlihat di layar. Widget yang di-scroll keluar akan dihancurkan untuk menghemat RAM. |
| **`_refreshBooks()`** | **State Hydration** | Fungsi ini melakukan *re-fetching*. Dengan memanggil `setState` pada variabel `Future`, kita memaksa `FutureBuilder` untuk me-reset state dan mengambil data terbaru dari server (Real-time update). |
| **`showDialog` (Await)** | **Blocking UI** | Pada tombol Hapus, `await showDialog` digunakan untuk memblokir eksekusi kode sampai user memilih "Ya" atau "Tidak". Mencegah penghapusan data yang tidak disengaja. |

### 4. Halaman Form Buku (`lib/screens/form_book_page.dart`)
Satu halaman yang menangani dua fungsi: **Create** dan **Update** (Polimorfisme UI).

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **`initState`** | **Lifecycle Hook** | Logika pengisian data lama (`_controller.text = ...`) diletakkan di sini agar hanya dijalankan sekali saat widget dibuat, bukan setiap kali widget di-*rebuild*. |
| **`int.tryParse`** | **Defensive Prog.** | Input `TextField` adalah String, API butuh Integer. `tryParse` mencoba mengonversi; jika gagal (user input huruf), ia mengembalikan `null`. Operator `?? 0` menangani `null` tersebut menjadi angka 0, mencegah aplikasi *crash*. |
| **Dual Logic** | **Code Reusability** | Logika `if (widget.book == null)` menentukan mode operasi. Jika `null` -> Panggil API **POST** (Add). Jika ada data -> Panggil API **PUT** (Update). Ini mengurangi duplikasi kode secara signifikan. |
| **Success Feedback** | **UX Flow** | Setelah operasi API sukses, aplikasi memanggil `showSuccessDialog`. Setelah user menutup dialog, `Navigator.pop` dipanggil untuk kembali ke Home dan memicu refresh data otomatis. |

### 5. Layanan API (`lib/data/api_service.dart`)
Kelas *Singleton-like* yang mengisolasi komunikasi jaringan.

| Komponen Kode | Konsep Teknis | Analisis Mendalam & Alur Eksekusi |
| :--- | :--- | :--- |
| **Header Injection** | **Security** | Setiap request (`GET`, `POST`, `PUT`, `DELETE`) otomatis disisipi header `Authorization: Bearer [token]`. Token diambil dari penyimpanan lokal aman (`SharedPreferences`). |
| **MIME Type** | **Protocol** | Header `Accept: application/json` dipasang agar Laravel tidak mengembalikan halaman HTML "Whoops" saat terjadi error server, melainkan JSON error yang bisa diparsing aplikasi. |
| **Status Handling** | **Normalization** | Menggunakan logika `if (status == 200 || status == 201)`. Ini menormalisasi respons sukses, karena standar HTTP mengembalikan 201 untuk *Resource Created*, yang sering dianggap "gagal" jika kode hanya mengecek 200. |

---

## 🛠️ Panduan Instalasi

### Tahap 1: Konfigurasi Backend (Laravel)
1.  **Database Migration**: `php artisan migrate` (Membuat tabel database, termasuk `personal_access_tokens`).
2.  **Running Server**: `php artisan serve` (Server berjalan di `http://127.0.0.1:8000`).

### Tahap 2: Konfigurasi Frontend (Flutter)
1.  **Dependency**: `flutter pub get` (Mengunduh paket `http` & `shared_preferences`).
2.  **Verifikasi**: Pastikan `baseUrl` di `api_service.dart` sudah benar.
3.  **Running**: `flutter run -d chrome`.
