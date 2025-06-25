from pydub import AudioSegment
import pysrt
import os

# Nama file (bisa diubah sesuai punya kamu)
audio_path = "myvoiceinput.wav"
srt_path = "myvoiceinput.srt"
output_dir = "output_audio_my_voice"

# Load audio
audio = AudioSegment.from_wav(audio_path)

# Load subtitle
subs = pysrt.open(srt_path)

# Bikin folder output kalo belum ada
os.makedirs(output_dir, exist_ok=True)

# Proses motong
for i, sub in enumerate(subs, 1):
    start_ms = sub.start.ordinal  # waktu mulai (ms)
    end_ms = sub.end.ordinal      # waktu selesai (ms)
    clip = audio[start_ms:end_ms]

    # Simpan file
    clip.export(f"{output_dir}/myvoice{i:03}.wav", format="wav")
    print(f"[✓] Clip {i:03} saved: {sub.text.strip()}")

print("✅ Semua bagian audio sudah dipotong dan disimpan di folder 'output_audio'")