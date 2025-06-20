# Swift Smart Home AI with Arduino (Jarvis Lite)

Proyek ini adalah **smart home system berbasis macOS app full Swift** yang terintegrasi dengan **Arduino Uno R3** dan menggunakan **machine learning**, **gesture & face recognition (model)**, serta **speaker recognition (model)** untuk kontrol rumah pintar dengan perintah suara pemilik rumah. App ini difokuskan untuk berjalan di Mac karena keterbatasan perangkat (iPhone), namun sudah disiapkan untuk bisa di-port ke iOS di masa depan.

---

## Fitur Utama

1. **Auto Open App** saat pengguna mendekati pintu (1–2 meter) via Bluetooth HM-10 BLE + Ultrasonic Sensor HC-SR04 (Optional)
2. **Face & Hand Gesture Recognition** eksklusif hanya untuk pemilik rumah.
3. **Koneksi Bluetooth** langsung dari Mac/IPhone ke Arduino Uno R3.
4. **Kontrol Selenoid** untuk membuka pintu otomatis setelah validasi berhasil.
5. **Speaker Recognition** untuk mengontrol berbagai fitur smart home (Hanya suara pemilik rumah terdaftar):
   - Menyalakan/mematikan lampu
   - Menyalakan/mematikan kipas/AC
   - Ganti mode rumah (dalam/luar)
6. **UI Sederhana & Intuitif** dengan tombol `Mulai Berbicara` dan `Berhenti Berbicara`.

---

## Teknologi & Hardware yang Digunakan (Simulasi)

| Komponen                 | Teknologi/Tools                           |
|--------------------------|-------------------------------------------|
| Bahasa Pemrograman & IDE | Swift (App Native) XCode                  |
|                          | C++ (Arduino Native) Arduino IDE          |
| Bluetooth                | CoreBluetooth + RSSI Detection            |
| Machine Learning         | CoreML + CreateML & Vision Framework      |
|                          | Vision Framework (Face Recognition)       |
|                          | CoreML + CreateML (Gesture Model)         |
|                          | SFSpeechRecognizer (Speaker Recognition)  |
| Hardware                 | Laptop (Mac - Running XCode)              |
|                          | Arduino Uno R3 (Micro Controller)         |
|                          | Modul Bluetooth (HM-10 BLE)               |
|                          | Sensor Jarak (HC-SR04)                    |
|                          | Door Lock (Selenoid 12V)                  |
|                          | Keamanan Tegangan (Relay Module)          |
|                          | Keamanan Tegangan (Resistor 5k ohm)       |
|                          | Tegangan Relay Selenoid (Adaptor 12V 1A)  |
|                          | Tegangan Arduino Uno R3 (Adaptor 9V 1A)   |
|                          | LED, Breadboard, Jumper & OLED            |
| Komunikasi               | Serial Bluetooth (UART)                   |

---

## Cara Kerja (Flow)

1. Arduino yang sudah diberi program dalam keadaan standby dan broadcasting Bluetooth.
2. Saat Mac/IPhone mendeteksi/mendekati device Arduino dalam jarak (2 meter max) dengan sensor ultrasonic yang divalidasi oleh RSSI HM-10 kuat (dekat), app otomatis terbuka.
3. App memulai validasi wajah dan gesture tangan kamu (Hanya Pemilik Rumah Terdaftar).
4. Jika validasi lolos, perintah `"OPEN"` dikirim ke Arduino → membuka selenoid pintu.
5. Setelah masuk, fitur speaker recognition aktif (Hanya Pemilik Rumah Terdaftar).
6. Kamu bisa mengucapkan perintah suara, seperti:
   - `"Nyalakan lampu utama, dapur, dan lainya"`
   - `"Ganti mode ke dalam rumah"`
7. Perintah dikirim via Bluetooth ke Arduino dan dieksekusi.

---

## Keamanan

1. Validasi biometric hanya bisa dilakukan oleh pemilik melalui wajah & gesture
2. Tidak akan mengaktifkan sistem jika tidak dikenali → lebih aman dari sekadar tombol

---

## Rencana Pengembangan

Jika dalam kasus smart home gunakan module MiniDSP UMA-8 (Microphone Array) dan pasang di beberapa titik dalam rumah untuk kontrol penuh dengan suara alih-alih menggunakan microfon HP
NOTE : MiniDSP UMA-8 memiliki jarak broadcast max 8 meter dan ada banyak alternatifnya

---

## Author

Pratama – @pratama6624
Apple Developer & Swift Enthusiast yang lagi ngegas jadi iOS Engineer Pro!
