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

## 💻 Penjelasan Detail Kode Program (Flutter)

### 1. Halaman Login (`lib/screens/login_page.dart`)

Halaman ini merupakan *entry point* aplikasi dan bertanggung jawab penuh atas proses autentikasi.

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Variabel State** | Pengelolaan Data | Menggunakan `_emailController`, `_passwordController`, dan `_isLoading` untuk mengelola input user dan status *loading* tombol. |
| **`bool _isLoading`** | UI Kontrol | Status yang mengontrol tampilan tombol utama; `true` menampilkan `CircularProgressIndicator`, `false` menampilkan teks "Masuk". |
| **`_login()` Function** | Logika Bisnis | Fungsi utama yang dipicu saat tombol "Masuk" ditekan. Mengirim kredensial via `ApiService` dan menunggu respons. |
| **Success Logic** | Navigasi | Jika `_apiService.login` mengembalikan `true`, token berhasil disimpan ke `shared_preferences`, dan user diarahkan ke `HomePage` menggunakan `Navigator.pushReplacement`. |
| **Failed Logic** | Error Handling | Jika login gagal, status *loading* dihentikan dan `SnackBar` ditampilkan dengan pesan error. |
| **`AppBar` Title** | Branding | Disetel ke **'Login Primamart'** dan diwarnai **coklat** (`Colors.brown`) sesuai ketentuan proyek. |
| **`TextButton`** | Navigasi | Tombol "Daftar disini" yang mengarahkan user ke halaman `RegisterPage`. |

### 2. Halaman Daftar (`lib/screens/register_page.dart`)

Halaman pendaftaran akun baru dengan fitur *self-recovery* dari error.

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Error Handling** | Robustness | Menggunakan blok **`try-catch-finally`** di fungsi `_register()` untuk menangani error jaringan atau server secara aman, serta memastikan *loading* berhenti (anti-spinner stuck). |
| **Validasi** | Input Safety | Mencegah user mendaftar jika kolom Nama, Email, atau Password kosong. |
| **Success Dialog** | Feedback | Setelah sukses, menampilkan <code>showSuccessDialog</code> (popup) dan kembali ke halaman Login. |
| **AppBar Title** | Branding | Disetel ke **'Daftar Akun Primamart'** untuk konsistensi. |

### 3. Halaman Utama (`lib/screens/home_page.dart`)

Dashboard utama yang menampilkan inventaris buku (fitur Read dan Delete).

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **`FutureBuilder`** | Data Fetching | Digunakan untuk mengambil daftar buku secara asinkron dari API melalui `_apiService.getBooks()`. |
| **`_refreshBooks()`** | State Management | Fungsi yang dipanggil di `initState()` dan setelah aksi CRUD (tambah/edit/hapus) untuk memperbarui tampilan daftar buku. |
| **Tombol Edit** | CRUD | Mengarahkan ke `FormBookPage` dengan membawa data buku (`book: book`) agar form terisi otomatis untuk pengeditan. |
| **Tombol Hapus** | CRUD Safety | Menampilkan <b>Alert Dialog Konfirmasi</b> sebelum memanggil `_apiService.deleteBook(book.id!)`. Jika sukses, menampilkan `showSuccessDialog` dan me-refresh daftar. |
| **`FloatingActionButton`** | Navigasi | Tombol <code>+</code> yang mengarahkan ke `FormBookPage` untuk menambah buku baru. |

### 4. Halaman Form Buku (`lib/screens/form_book_page.dart`)

Digunakan untuk logika penambahan dan pengubahan data inventaris.

| Blok Kode | Kategori | Penjelasan Detail |
| :--- | :--- | :--- |
| **Dynamic Title** | UI/Navigasi | Judul AppBar berubah antara "Tambah Buku Primamart" atau "Edit Buku Primamart" berdasarkan parameter `widget.book` (null atau ada data). |
| **`_submit()` Function** | Logic | Menangani konversi input string ke `int` (untuk Harga, Jumlah, Volume) dan memanggil `addBook` atau `updateBook` melalui `ApiService`. |
| **Try-Catch** | Robustness | Melindungi proses pengiriman data agar *loading* selalu berhenti, bahkan jika konversi tipe data atau koneksi API gagal. |
| **`_isLoading`** | UI Kontrol | Mengontrol tampilan tombol "Simpan"/"Update" menjadi `CircularProgressIndicator` saat data sedang diproses. |

---

### 5. File Pendukung Utama

| File | Keterangan |
| :--- | :--- |
| **`main.dart`** | Entry point yang mengatur tema aplikasi ke **Coklat** dan menjalankan `LoginPage` sebagai halaman awal. |
| **`api_service.dart`** | Kelas penghubung HTTP utama. Diperbarui untuk menerima status code `200` atau `201` pada operasi `POST` dan mengirimkan header `Accept: application/json`. |
| **`success_dialog.dart`** | Widget kustom yang menyediakan *popup dialog* seragam untuk umpan balik keberhasilan (success feedback) di seluruh aplikasi. |

---

## 🛠️ Cara Instalasi & Menjalankan

1.  **Backend (Laravel)**: Pastikan semua migrasi sudah dijalankan (`php artisan migrate`) dan server nyala: `php artisan serve`.
2.  **Frontend (Flutter)**: Jalankan aplikasi di Chrome: `flutter run -d chrome`.
