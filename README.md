<!DOCTYPE html>
<html>
<head>
    <title>README - Responsi 2 Mobile Paket 3</title>
    <meta charset="UTF-8">
</head>
<body>

    <h1>Responsi 2 Mobile Paket 3 - Inventaris Primamart</h1>
    <p>Aplikasi mobile berbasis <b>Flutter</b> untuk manajemen inventaris barang (Buku) di supermarket "Primamart". Aplikasi ini menggunakan <b>Laravel</b> sebagai Backend API.</p>

    <hr>

    <h2>👤 Identitas Mahasiswa</h2>
    <table border="1" cellpadding="5" cellspacing="0">
        <thead>
            <tr>
                <th>Atribut</th>
                <th>Keterangan</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><b>Nama</b></td>
                <td>[ISI NAMA LENGKAP KAMU DISINI]</td>
            </tr>
            <tr>
                <td><b>NIM</b></td>
                <td>H1D023040</td>
            </tr>
            <tr>
                <td><b>Shift Baru</b></td>
                <td>[ISI SHIFT BARU, Contoh: E]</td>
            </tr>
            <tr>
                <td><b>Shift Asal</b></td>
                <td>[ISI SHIFT ASAL, Contoh: A]</td>
            </tr>
        </tbody>
    </table>

    <hr>

    <h2>🎥 Video Demo Aplikasi</h2>
    <p>Berikut adalah link video demonstrasi penggunaan aplikasi:</p>
    <p><b><a href="[LINK VIDEO DEMO DISINI]" target="_blank">[KLIK DISINI UNTUK MELIHAT VIDEO DEMO]</a></b></p>
    <p><i>(Catatan: Upload video ke YouTube atau Google Drive, lalu tempel link-nya di atas)</i></p>

    <hr>

    <h2>🔌 Spesifikasi API (Laravel)</h2>
    <p>Backend dibangun menggunakan framework Laravel dengan fitur Token-based Authentication (Sanctum).</p>

    <h3>1. Authentication</h3>
    <table border="1" cellpadding="5" cellspacing="0">
        <thead>
            <tr>
                <th>Method</th>
                <th>Endpoint</th>
                <th>Deskripsi</th>
                <th>Parameter Body (JSON)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>POST</code></td>
                <td><code>/api/register</code></td>
                <td>Mendaftarkan akun baru</td>
                <td><code>name</code>, <code>email</code>, <code>password</code></td>
            </tr>
            <tr>
                <td><code>POST</code></td>
                <td><code>/api/login</code></td>
                <td>Masuk & mendapatkan Token</td>
                <td><code>email</code>, <code>password</code></td>
            </tr>
            <tr>
                <td><code>POST</code></td>
                <td><code>/api/logout</code></td>
                <td>Hapus token (Keluar)</td>
                <td><i>(Header Authorization: Bearer Token)</i></td>
            </tr>
        </tbody>
    </table>

    <h3>2. Inventaris Buku (CRUD)</h3>
    <p>Semua endpoint di bawah membutuhkan Header: <code>Authorization: Bearer &lt;token&gt;</code></p>
    <table border="1" cellpadding="5" cellspacing="0">
        <thead>
            <tr>
                <th>Method</th>
                <th>Endpoint</th>
                <th>Deskripsi</th>
                <th>Parameter Body (JSON)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>GET</code></td>
                <td><code>/api/books</code></td>
                <td>Mengambil semua data buku</td>
                <td>-</td>
            </tr>
            <tr>
                <td><code>POST</code></td>
                <td><code>/api/books</code></td>
                <td>Menambah buku baru</td>
                <td><code>judul</code>, <code>harga</code>, <code>jumlah</code>, <code>tanggal_masuk</code>, <code>volume</code>, <code>penulis</code>, <code>penerbit</code></td>
            </tr>
            <tr>
                <td><code>PUT</code></td>
                <td><code>/api/books/{id}</code></td>
                <td>Mengupdate data buku</td>
                <td><code>judul</code>, <code>harga</code>, <code>jumlah</code>, <code>tanggal_masuk</code>, <code>volume</code>, <code>penulis</code>, <code>penerbit</code></td>
            </tr>
            <tr>
                <td><code>DELETE</code></td>
                <td><code>/api/books/{id}</code></td>
                <td>Menghapus buku</td>
                <td>-</td>
            </tr>
        </tbody>
    </table>

    <hr>

    <h2>💻 Penjelasan Kode Program (Flutter)</h2>

    <h3>1. Layanan Data (Folder <code>lib/data/</code>)</h3>
    <ul>
        <li><b><code>api_service.dart</code></b>: 
            File ini berfungsi sebagai jembatan antara Flutter dan Laravel. Berisi semua fungsi HTTP request (Login, Register, CRUD).</li>
    </ul>

    <h3>2. Model Data (Folder <code>lib/model/</code>)</h3>
    <ul>
        <li><b><code>book.dart</code></b>: 
            Merupakan representasi objek Buku. Digunakan untuk konversi data antara JSON dari API dan objek Dart di aplikasi (<code>fromJson</code> dan <code>toJson</code>).</li>
    </ul>

    <h3>3. Tampilan Layar (Folder <code>lib/screens/</code>)</h3>
    <ul>
        <li><b><code>login_page.dart</code></b>: Halaman awal aplikasi. Memiliki form login dan link navigasi ke Register.</li>
        <li><b><code>register_page.dart</code></b>: Form pendaftaran user baru. Menggunakan <code>try-catch-finally</code> dan menampilkan <b>Popup Dialog</b> sukses setelah registrasi.</li>
        <li><b><code>home_page.dart</code></b>: Halaman utama aplikasi ("Inventaris Buku Primamart"). Menampilkan daftar buku, tombol logout, serta fungsi untuk refresh data dan memicu hapus/edit.</li>
        <li><b><code>form_book_page.dart</code></b>: Form serbaguna untuk Tambah atau Edit buku. Memiliki validasi dan loading indicator.</li>
    </ul>

    <h3>4. Widget Tambahan (Folder <code>lib/widget/</code>)</h3>
    <ul>
        <li><b><code>success_dialog.dart</code></b>: Reusable widget untuk menampilkan <b>Popup Dialog</b> dengan ikon centang saat aksi berhasil (sukses CRUD dan Register).</li>
    </ul>

    <h3>5. Entry Point</h3>
    <ul>
        <li><b><code>main.dart</code></b>: Mengatur tema aplikasi dengan warna utama <b>Coklat</b>. Menetapkan judul aplikasi ("Responsi 2 Mobile Paket 3 H1D023040") dan menjalankan <code>LoginPage</code> sebagai halaman awal.</li>
    </ul>

    <hr>

    <h2>🛠️ Cara Instalasi & Menjalankan</h2>
    <ol>
        <li><b>Backend (Laravel)</b>: Jalankan migrasi dan server: <code>php artisan migrate</code> dan <code>php artisan serve</code>.</li>
        <li><b>Frontend (Flutter)</b>: Jalankan aplikasi di Chrome: <code>flutter run -d chrome</code>.</li>
    </ol>

</body>
</html>