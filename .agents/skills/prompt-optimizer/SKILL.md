---
name: prompt-optimizer
description: >-
  Kullanıcının verdiği ham promptları analiz eder, eksik noktaları tespit eder ve
  yapay zeka modelleri (LLM'ler) için en yüksek performansı, netliği ve doğruluğu
  sağlayacak şekilde yapılandırılmış (Rol, Bağlam, Görev, Kısıtlamalar, Çıktı Formatı, Örnekler)
  profesyonel promptlara dönüştürür.
---

# Prompt Optimizer (Prompt Geliştirici & İyileştirici)

Bu beceri (skill), kullanıcının girdiği herhangi bir promptu veya isteği inceler ve aşağıdaki prompt mühendisliği (Prompt Engineering) standartlarına göre optimize eder.

## Optimizasyon Adımları

1. **Analiz**: Kullanıcının asıl amacını, hedef modelini ve eksik kalan bağlamları belirle.
2. **Yapılandırma**: Promptu şu bölümlere ayırarak yeniden yaz:
   - **Persona / Rol**: Modelin hangi uzman rolünü üstleneceği.
   - **Bağlam (Context)**: Arka plan bilgisi ve ortam detayları.
   - **Görev (Task / Objective)**: Yapılması istenen işin net, adım adım tanımı.
   - **Kısıtlamalar & Kurallar (Constraints)**: Kaçınılması gerekenler, ton, dil, format sınırlamaları.
   - **Çıktı Formatı (Output Format)**: JSON, Markdown, kod bloğu veya tablo gibi beklenen format.
   - **Few-Shot / Örnekler (Opsiyonel)**: Varsa girdi/çıktı örnekleri.
3. **Seçenek Sunumu**: Kullanıcıya hem **Hızlı/Kısa Versiyon** hem de **Detaylı/Gelişmiş Versiyon** sun.
