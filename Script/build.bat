windres resources.rc -o resources.o
gcc -O2 -mconsole .\5G-Solution-5000-COM-AT.c resources.o -o "5G Solution 5000 COM AT.exe" -lsetupapi -luuid