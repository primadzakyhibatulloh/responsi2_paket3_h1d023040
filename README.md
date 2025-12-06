# Responsi 2 Mobile Paket 3 - Inventaris Primamart

Aplikasi mobile berbasis **Flutter** untuk manajemen inventaris barang (Buku) di supermarket "Primamart". Aplikasi ini menggunakan **Laravel** sebagai Backend API.

---

## 👤 Identitas Mahasiswa
| Atribut | Keterangan |
| :--- | :--- |
| **Nama** | [ISI NAMA LENGKAP KAMU DISINI] |
| **NIM** | H1D023040 |
| **Shift Baru** | [ F] |
| **Shift Asal** | [ B] |

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

Berikut adalah penjelasan fungsi utama dari setiap file dalam aplikasi ini:

### 1. Layanan Data (`lib/data/`)
* **`api_service.dart`**: File ini berfungsi sebagai jembatan antara Flutter dan Laravel. Berisi semua fungsi HTTP request (Login, Register, CRUD) dan manajemen token.

### 2. Model Data (`lib/model/`)
* **`book.dart`**: Representasi objek Buku (data fields Judul, Harga, Jumlah, dll.) yang digunakan untuk konversi data antara JSON dari API dan objek Dart (<code>fromJson</code> dan <code>toJson</code>).

### 3. Tampilan Layar (`lib/screens/`)
* **`login_page.dart`**: Halaman awal aplikasi dengan form login.
Kode,Penjelasan Fungsi
class LoginPage extends StatefulWidget,Merupakan widget yang memerlukan perubahan status (seperti loading dan input teks) sehingga menggunakan StatefulWidget.
final _emailController = ...,TextEditingController untuk mengambil nilai yang diketik pengguna pada kolom Email.
final _passwordController = ...,TextEditingController untuk mengambil nilai yang diketik pengguna pada kolom Password.
final ApiService _apiService = ApiService();,Membuat instance dari kelas <code>ApiService</code> untuk melakukan komunikasi HTTP (panggilan API).
bool _isLoading = false;,Variabel state yang mengontrol apakah tombol login harus menampilkan indikator loading (true) atau teks tombol (false).
* **`register_page.dart`**: Form pendaftaran user baru. Menggunakan <code>try-catch-finally</code> dan menampilkan Popup Dialog sukses setelah registrasi.
* **`home_page.dart`**: Halaman utama ("Inventaris Buku Primamart"). Menampilkan daftar buku, tombol logout, dan fungsi untuk hapus/edit.
* **`form_book_page.dart`**: Form serbaguna untuk Tambah atau Edit buku.

### 4. Widget Tambahan (`lib/widget/`)
* **`success_dialog.dart`**: Widget kustom untuk menampilkan Popup Dialog saat aksi berhasil.

---

## 🛠️ Cara Instalasi & Menjalankan
1.  **Backend (Laravel)**: Jalankan migrasi dan server: `php artisan migrate` dan `php artisan serve`.
2.  **Frontend (Flutter)**: Jalankan aplikasi di Chrome: `flutter run -d chrome`.
