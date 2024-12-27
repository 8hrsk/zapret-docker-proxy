@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Директория с конфигурационными файлами
set CONFIG_DIR=configs/zapret.configs
set TARGET_CONFIG=config
set IGNORE_DIR=bin

:: Проверка наличия директории с конфигурациями
if not exist "%CONFIG_DIR%" (
    echo Ошибка: Директория с конфигурациями "%CONFIG_DIR%" не найдена.
    pause
    exit /b 1
)

:: Составление списка конфигурационных файлов, исключая .txt и содержимое %IGNORE_DIR%
set FILES=
for %%F in ("%CONFIG_DIR%\*") do (
    if not "%%~xF"==".txt" (
        if /I not "%%~nxF"=="%IGNORE_DIR%" (
            set FILES=!FILES! %%~nxF
        )
    )
)

:: Проверка наличия конфигурационных файлов
if "!FILES!"=="" (
    echo Ошибка: В директории "%CONFIG_DIR%" нет доступных конфигурационных файлов.
    pause
    exit /b 1
)

:: Вывод списка конфигураций
echo Доступные конфигурации:
set INDEX=0
for %%F in (!FILES!) do (
    set /a INDEX+=1
    echo !INDEX!. %%F
    set CONFIG_!INDEX!=%%F
)

:: Запрос у пользователя выбора конфигурации
set /p CHOICE=Введите номер конфигурации, которую вы хотите использовать: 
if not defined CHOICE (
    echo Ошибка: Не введен номер.
    pause
    exit /b 1
)

:: Проверка, является ли выбор числом
for /f "tokens=* delims=0123456789" %%C in ("%CHOICE%") do (
    echo Ошибка: Введите корректный номер (только цифры).
    pause
    exit /b 1
)

:: Получение выбранной конфигурации
set SELECTED_FILE=!CONFIG_%CHOICE%!
if not defined SELECTED_FILE (
    echo Ошибка: Неверный выбор. Конфигурация с номером %CHOICE% не найдена.
    pause
    exit /b 1
)

:: Копирование выбранного файла
copy "%CONFIG_DIR%\!SELECTED_FILE!" "%TARGET_CONFIG%" >nul
if errorlevel 1 (
    echo Ошибка: Не удалось скопировать файл.
    pause
    exit /b 1
)
echo Конфигурация "!SELECTED_FILE!" успешно применена.

:: Запуск Docker-контейнера
echo Запуск контейнера...
docker-compose up -d
if errorlevel 1 (
    echo Ошибка: Не удалось запустить контейнер.
    pause
    exit /b 1
)
echo Контейнер успешно запущен.

pause
exit /b 0
