@echo off
setlocal enabledelayedexpansion

:: ========== CONFIG ==========
set YTDLP=C:\Users\tadee\AppData\Local\Programs\Python\Python312\Scripts\yt-dlp.exe
set CHANNELS=C:\YTConv\auto\channels.txt
set ARCHIVE=C:\YTConv\auto\archive.txt
set DOWNLOAD=C:\YTConv\auto\download
set LOG=C:\YTConv\auto\log.txt
set FFMPEG=C:\ffmpeg\bin\ffmpeg.exe
:: ============================

echo [%date% %time%] [INIT] Script started > "%LOG%"
echo [%date% %time%] [INIT] Working dir: %CD% >> "%LOG%"

if not exist "C:\YTConv\auto" mkdir "C:\YTConv\auto"
if not exist "%DOWNLOAD%" mkdir "%DOWNLOAD%"

if not exist "%YTDLP%" (
    echo [%date% %time%] [FATAL] yt-dlp not found >> "%LOG%"
    exit /b 1
)
if not exist "%CHANNELS%" (
    echo [%date% %time%] [FATAL] channels.txt not found >> "%LOG%"
    exit /b 1
)
echo [%date% %time%] [CHECK] All files found >> "%LOG%"

echo [%date% %time%] [LOOP] ===== Starting channel loop ===== >> "%LOG%"

set CH_NUM=0
for /f "usebackq tokens=* delims=" %%A in ("%CHANNELS%") do (
    set /a CH_NUM+=1
    set "URL=%%A"
    echo. >> "%LOG%"
    echo [%date% %time%] [LOOP] ============================== >> "%LOG%"
    echo [%date% %time%] [LOOP] Channel #!CH_NUM!: [!URL!] >> "%LOG%"
    
    if "!URL!"=="" (
        echo [%date% %time%] [LOOP] Blank line, skipping >> "%LOG%"
    ) else (
        echo [%date% %time%] [LOOP] Starting yt-dlp download... >> "%LOG%"
        
        :: --newline forces each progress update onto its own line in the log
        "%YTDLP%" --newline --write-subs en --embed-subs -I 1:2 --download-archive "%ARCHIVE%" -P "%DOWNLOAD%" -o "%%(title)s [%%(id)s].%%(ext)s" -f "bv*[height<=480]+ba[ext=m4a]/b[height<=480]" --merge-output-format mp4 --ffmpeg-location "%FFMPEG%" "!URL!" >> "%LOG%" 2>&1
        
        set EXITCODE=!ERRORLEVEL!
        echo [%date% %time%] [LOOP] yt-dlp finished with exit code: !EXITCODE! >> "%LOG%"
    )
    
    echo [%date% %time%] [LOOP] Finished channel #!CH_NUM! >> "%LOG%"
)

echo. >> "%LOG%"
echo [%date% %time%] [DONE] Processed %CH_NUM% channels ===== >> "%LOG%"