@echo off
cd /d "D:\github\firmware"

echo Repo güncelleniyor...
git pull origin main

echo Değişiklikler ekleniyor...
git add .

echo Commit yapılıyor...
git commit -m "Auto commit %date% %time%" || echo "Commit yapılacak değişiklik yok."

echo Değişiklikler gönderiliyor...
git push origin main

echo İşlem tamamlandı!
exit