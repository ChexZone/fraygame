@REM :: Go to the parent directory
@REM cd ..

:: Create the builds folder if it doesn't exist
@REM if not exist builds mkdir builds

mkdir game
xcopy ..\conf.lua game\ /Y
xcopy ..\main.lua game\ /Y
xcopy ..\game game\game\ /E /I /Y
xcopy ..\chexcore game\chexcore\ /E /I /Y
xcopy ..\tiled game\tiled\ /E /I /Y

:: Zip the files into "game.love" in the builds folder
:: Adjust the path to 7z.exe if needed
@REM copy builds\lovebrew.toml .
"C:\Program Files\7-Zip\7z.exe" a -tzip game_3ds.zip game\ lovebrew.toml
@REM del lovebrew.toml
rmdir /S /Q game

@REM if not exist builds/3ds mkdir builds/3ds


@REM cd builds/browser

@REM python -m http.server 8000
@REM if %errorlevel% neq 0 (
@REM     echo Error: Failed to start Python HTTP server.
@REM     pause
@REM     exit /b %errorlevel%
@REM )
pause