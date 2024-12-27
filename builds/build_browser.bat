:: Go to the parent directory
cd ..

:: Create the builds folder if it doesn't exist
if not exist builds mkdir builds

:: Zip the files into "game.love" in the builds folder
:: Adjust the path to 7z.exe if needed
"C:\Program Files\7-Zip\7z.exe" a -tzip builds\game.love conf.lua main.lua game\ chexcore\ tiled\

if not exist builds/browser mkdir builds/browser

npx love.js.cmd "%cd%\builds\game.love" "%cd%\builds\browser" -c -t Chexcore -m 100000000
if %errorlevel% neq 0 (
    echo Error: Failed to run love.js.
    pause
    exit /b %errorlevel%
)
cd builds/browser

python -m http.server 8000
if %errorlevel% neq 0 (
    echo Error: Failed to start Python HTTP server.
    pause
    exit /b %errorlevel%
)
pause