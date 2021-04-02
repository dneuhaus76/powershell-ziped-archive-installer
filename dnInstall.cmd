@echo off
powershell.exe "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
cd /d "%~dp0"
powershell.exe "%~dp0%~n0.ps1"