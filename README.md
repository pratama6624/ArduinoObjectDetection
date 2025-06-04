# Swift Smart Home AI with Arduino

Proyek ini adalah **smart home system berbasis macOS app full Swift** yang terintegrasi dengan **Arduino Uno R3** dan menggunakan **machine learning**, **gesture & face recognition**, serta **speech command** untuk kontrol rumah pintar. App ini difokuskan untuk berjalan di Mac karena belum memiliki perangkat iPhone, namun sudah disiapkan untuk bisa di-port ke iOS di masa depan.

---

## Fitur Utama

1. **Auto Unlock App** saat pengguna mendekati pintu (1–2 meter) via Bluetooth.
2. **Face & Hand Gesture Recognition** eksklusif hanya untuk pemilik rumah.
3. **Koneksi Bluetooth** langsung dari Mac ke Arduino Uno R3.
4. **Kontrol Selenoid** untuk membuka pintu otomatis setelah validasi berhasil.
5. **Speech Recognition** untuk mengontrol berbagai fitur smart home:
   - Menyalakan/mematikan lampu
   - Ganti mode rumah (dalam/luar)
6. **UI Sederhana & Intuitif** dengan tombol `Mulai Berbicara` dan `Berhenti Berbicara`.

---

## Teknologi yang Digunakan

| Komponen                 | Teknologi/Tools                     |
|--------------------------|-------------------------------------|
| macOS App                | Swift (AppKit)                      |
| Bluetooth                | CoreBluetooth + RSSI detection      |
| Face Recognition         | Vision Framework                    |
| Gesture Recognition      | CoreML (hand pose model / custom)   |
| Speech Recognition       | SFSpeechRecognizer                  |
| Hardware                 | Arduino Uno R3 + HC-05 / HM-10      |
| Komunikasi               | Serial Bluetooth (UART)             |

---

## Hardware Requirements

- Arduino Uno R3
- Modul Bluetooth (HM-10 BLE)
- Modul Selenoid Lock
- Relay Module
- Power Supply 12V untuk selenoid
- Kabel jumper
- Mac dengan kamera

---

## Cara Kerja (Flow)

1. Arduino dalam keadaan standby dan broadcasting Bluetooth.
2. Saat Mac mendeteksi device Arduino dengan RSSI kuat (dekat), app otomatis terbuka.
3. App memulai validasi wajah dan gesture tangan kamu.
4. Jika validasi lolos, perintah `"OPEN"` dikirim ke Arduino → membuka selenoid pintu.
5. Setelah masuk, fitur speech recognition aktif.
6. Kamu bisa mengucapkan perintah suara, seperti:
   - `"Nyalakan lampu 1"`
   - `"Ganti mode ke dalam rumah"`
7. Perintah dikirim via Bluetooth ke Arduino dan dieksekusi.

---

## Keamanan

1. Validasi biometric hanya bisa dilakukan oleh pemilik melalui wajah & gesture
2. Tidak akan mengaktifkan sistem jika tidak dikenali → lebih aman dari sekadar tombol

---

## Rencana Pengembangan

1. Porting app ke iOS untuk iPhone
2. Notifikasi saat pintu dibuka/tutup

---

## Author

Pratama – @pratama6624
Apple Developer & Swift Enthusiast yang lagi ngegas jadi iOS Engineer Pro!
