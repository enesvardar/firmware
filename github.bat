@echo off
cd /d "D:\github\firmware"

echo Updating repository...
git pull origin main

echo Adding changes...
git add .

echo Committing...
git commit -m "Auto commit %date% %time%" || echo "No changes to commit."

echo Pushing changes...
git push --force origin main

echo Process completed!
exit