# Toko Kilat

Proyek latihan untuk sesi **Menilai Kode Flutter**. Aplikasinya jalan, demo lancar.
Tugas kalian: menilai apakah kodenya **aman, efisien, benar, dan rapi**, lalu membuktikannya dengan tool.

Semua key, token, dan secret di proyek ini **palsu** dan dibuat khusus untuk latihan.

## Menjalankan

```bash
flutter pub get
```

```bash
flutter run
```

Login dengan email dan password apa saja (asal tidak kosong).

## Sebelum mulai

```bash
git checkout -b coaching/flutter-tools
```

## Langkah praktik

Pakai pola yang sama untuk setiap langkah: **Kenali → Buktikan → Pahami → Perbaiki & Verifikasi**.

### Langkah 1: Aman? Cek secret

macOS / Linux:

```bash
grep -rniE "key|token|secret" lib/
```

Windows (PowerShell):

```powershell
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "key|token|secret"
```

- Mana yang benar-benar secret, mana yang cuma kebetulan cocok (mis. `super.key`)?
- Ada file yang ikut masuk APK lewat `assets` di `pubspec.yaml`?
- Token login disimpan di mana?

### Langkah 2: Efisien? Ukur rebuild & request

1. `flutter run`, buka DevTools → **Performance** → aktifkan **Track widget build counts**
2. Di halaman utama: scroll, ketik di kolom cari, tekan tombol tambah ke keranjang
3. Buka **Rebuild Stats**: widget mana yang rebuild paling banyak? Catat angkanya
4. Buka tab **Network**: ada request yang sama berulang?
5. Perbaiki, lalu ukur lagi. Angkanya turun?

### Langkah 3: Benar? `flutter analyze`

```bash
flutter analyze
```

1. Catat jumlah issue di baris terakhir
2. Pilih 3 issue, baca: tingkat, pesan, lokasi, nama aturan
3. Cari `use_build_context_synchronously`, perbaiki manual dengan cek `context.mounted`
4. Cari `// ignore:` di kode. Ada alarm yang sengaja dimatikan?

Coba juga: buka keranjang, tekan **Bayar Sekarang**, lalu langsung tekan Back. Apa yang muncul di konsol?

### Langkah 4: `dart fix`

```bash
dart fix --dry-run
```

```bash
dart fix --apply
```

```bash
git diff
```

```bash
flutter analyze
```

- Berapa issue yang berkurang dibanding Langkah 3?
- Yang tersisa: kenapa `dart fix` tidak bisa memperbaikinya?

### Bonus: Rapi?

- File mana yang mengerjakan terlalu banyak tugas sekaligus?
- Widget mana yang memanggil API atau penyimpanan secara langsung?
- Logika bisnis (diskon, ongkir) ada di mana? Seharusnya di mana?
- Apakah struktur foldernya konsisten?
