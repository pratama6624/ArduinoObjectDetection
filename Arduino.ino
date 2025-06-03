// Kode nya masih hanya untuk LED saja
// Belum ada Relay Module, Selenoid, dan OLED Module

void setup() {
  Serial.begin(9600);

  // Set semua pin D2 - D6 sebagai OUTPUT dan matikan
  for (int pin = 2; pin <= 6; pin++) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
  }
}

void loop() {
  static String input = "";

  // Baca data selama tersedia
  while (Serial.available()) {
    char c = Serial.read();

    // Akhir pesan dari Swift (newline)
    if (c == '\n') {
      processCommand(input);
      input = ""; // reset
    } else {
      input += c;
    }
  }
}

void processCommand(String cmd) {
  if (cmd.startsWith("F")) {
    int pinNum = cmd.substring(1).toInt();

    // Matikan semua dulu
    for (int pin = 2; pin <= 6; pin++) {
      digitalWrite(pin, LOW);
    }

    // Nyalakan satu pin sesuai command (misal F3 → pin 3)
    if (pinNum >= 2 && pinNum <= 6) {
      digitalWrite(pinNum, HIGH);
    }
  }
}
