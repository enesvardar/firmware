@echo off
cd /d "D:\github\firmware"
git add .
git commit -m "Otomatik güncelleme"
git push origin main
pause