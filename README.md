Swift Smart Home AI with Arduino (Jarvis Lite)

**Jarvis Lite** adalah sistem smart home berbasis **macOS app full Swift** yang terintegrasi dengan **Arduino Uno R3**. Sistem ini menggabungkan kontrol suara berbasis **machine learning**, **face & gesture recognition**, dan **speaker recognition**. Dibuat khusus untuk Mac karena keterbatasan perangkat (iPhone), namun siap di-porting ke iOS di masa depan.
---

## Rangkaian 1

<img width="1391" alt="Screenshot 2025-06-24 at 12 08 05 AM" src="https://github.com/user-attachments/assets/c6c15b42-0df1-45fc-8154-d63e8483523d" />

## Rangkaian 2

<img width="1388" alt="Screenshot 2025-06-27 at 4 39 31 PM" src="https://github.com/user-attachments/assets/c6a7436c-7128-4b49-8c72-abdb6f4dbefa" />

## 🚀 Fitur Utama

1. **Auto Launch App** saat pengguna mendekati rumah via BLE + sensor ultrasonic (opsional).
2. **Face & Hand Gesture Recognition** eksklusif untuk pemilik rumah.
3. **Kontrol Pintu Otomatis (Selenoid Lock)** via Bluetooth setelah validasi wajah/gesture.
4. **Kontrol Perangkat Rumah** lewat suara (hanya oleh pemilik):
   - Lampu, kipas, AC, dan lainnya.
5. **Mode Sistem:**
   - Mode Santai (idle)
   - Mode Kontrol (aktif perintah suara)
6. **Speaker Recognition** – kontrol hanya bisa dijalankan oleh suara terverifikasi.
7. **UI Simple & Intuitif** – tombol `Mulai Bicara` & `Berhenti Bicara`.

---

## 🛠️ Teknologi & Hardware

| Komponen           | Detail                                      |
|--------------------|---------------------------------------------|
| Bahasa             | Swift (Xcode) + C++ (Arduino IDE)           |
| Bluetooth          | CoreBluetooth + HM-10 BLE (UART)            |
| ML & Vision        | CoreML, CreateML, Vision (Face & Gesture)   |
| Speech             | SFSpeechRecognizer + CreateML (Speaker)     |
| Komunikasi         | Serial Bluetooth (HM-10 UART)               |
| Mac                | Sebagai pusat kontrol & tampilan UI         |
| Arduino Uno R3     | Mikrokontroler eksekutor perintah           |
| Sensor & Aktuator  | HC-SR04, Relay, LED, Selenoid Lock 12V      |
| Daya               | Arduino: Adaptor 9V 1A, Selenoid: 12V 1A    |
| Proteksi           | Dioda 1N4007, Relay, Resistor, dll          |

---

## 🔁 Flow Sistem

1. Arduino standby & broadcast Bluetooth HM-10.
2. Mac mendeteksi sinyal BLE + (opsional) sensor jarak → buka aplikasi otomatis.
3. Validasi wajah + gesture.
4. Jika lolos, kirim perintah `"OPEN"` → Arduino membuka kunci pintu.
5. Aktifkan mode kontrol suara → pengguna bisa memberi perintah seperti:
   - `"Nyalakan lampu satu"`
   - `"Matikan semua"`
   - `"Ganti mode rumah"`
6. Perintah dikirim via Bluetooth ke Arduino dan dieksekusi sesuai kode.

---

## 🔐 Keamanan & Perlindungan

| Potensi Celah                        | Solusi                                                                 |
|-------------------------------------|------------------------------------------------------------------------|
| HM-10 BLE terbuka                   | Atur password AT+PASS + pairing authenticated AT+TYPE3                |
| Perintah langsung diproses Arduino  | Tambahkan token/kode prefix unik sebelum dieksekusi                    |
| Mode kontrol bisa diakses bebas     | Tambahkan keyword rahasia + verifikasi PIN atau suara                 |
| Kontrol terus aktif tanpa batas     | Timer auto-exit jika tidak ada suara dalam 30 detik                   |
| Suara bisa dipalsukan               | Gunakan speaker recognition model + validasi ulang                    |
| Data BLE bisa di-sniff              | Encode sederhana (XOR key) + validasi token                           |
| Arduino terlalu polos               | Validasi panjang & isi data sebelum proses, sanitasi input            |

---

## ⚙️ Rencana Upgrade

- Ganti **Arduino Uno R3** dengan **ESP32 BLE** untuk dukungan keamanan + performa BLE lebih baik.
- Gunakan **Microphone Array (MiniDSP UMA-8)** di beberapa titik rumah.
- Tambahkan **cloud integration** atau HomeKit untuk smart scene dan integrasi Siri.
- Buat sistem enkripsi ringan antara app & Arduino (encode UUID/kode).

---

## 🧠 Latar Belakang

> Kenapa bikin sendiri?

Karena tujuan utamanya bukan cuma “menggunakan” teknologi, tapi **memahami, menguasai, dan mengembangkannya**. Jarvis Lite dibuat sebagai langkah nyata untuk eksplorasi gabungan software & hardware berbasis AI + IoT.

---

## 🙋 Author

**Pratama – [@pratama6624](https://github.com/pratama6624)**  
Apple Developer & Swift Enthusiast. Sedang proses naik level jadi iOS Engineer Pro yang ngerti dalemannya, bukan cuma pake doang! ⚡

---
