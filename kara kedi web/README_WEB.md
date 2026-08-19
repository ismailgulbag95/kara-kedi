# 🌐 Kara Kedi: Web Sürümü Modülü

Bu klasör, ana Godot oyunumuzun tarayıcı üzerinden oynanabilir **Web Sürümünü** içerir.

---

## 📂 Dosya Yapısı

- 📄 **`Kara_Kedi_Web_Surumu.html`**: Tek dosyalık, 147 KB boyutunda bağımsız web oyunudur. Çift tıklanarak doğrudan tüm tarayıcılarda (Chrome, Safari, Edge vb.) çalışır. Arkadaşlarınızla doğrudan bu dosyayı paylaşabilirsiniz.
- 📄 **`index.html`** & **`game.js`**: Web sürümünün kaynak ve web sunucusu dosyalarıdır.
- ⚡ **`guncelle_web_surumu.ps1`**: Ana Godot projesinde yaptığımız ve onayladığınız yenilikleri (yeni silahlar, animasyonlar, bosslar vb.) tek tıkla Web sürümüne senkronize eden derleyici/güncelleyici betiktir.
- 🚀 **`baslat_web.bat`**: Yerel tarayıcıda `http://localhost:8000` üzerinden oyunu başlatan kısayoldur.

---

## 🔄 Gelecekteki Güncelleme İş Akışı
1. Ana Godot projesinde geliştirmeler yapılır ve Godot'ta test edilir (F5).
2. Onayladığınız özellikler web sürümüne aktarılmak istendiğinde `guncelle_web_surumu.ps1` çalıştırılarak web sürümü otomatik senkronize edilir.
