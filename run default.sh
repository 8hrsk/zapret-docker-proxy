#!/bin/bash

# Директория с конфигурационными файлами
CONFIG_DIR="./configs"
# Имя целевого файла конфигурации
TARGET_CONFIG="./config"
# Имя директории, которую нужно игнорировать
IGNORE_DIR="bin"

# Проверка наличия директории с конфигурациями
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Ошибка: Директория с конфигурациями $CONFIG_DIR не найдена."
  exit 1
fi

# Получение списка конфигурационных файлов, исключая директорию bin и файлы .txt
CONFIG_FILES=($(find "$CONFIG_DIR" -maxdepth 1 -type f -not -name "*.txt" -not -path "$CONFIG_DIR/$IGNORE_DIR/*" -exec basename {} \;))

# Проверка наличия конфигурационных файлов
if [ ${#CONFIG_FILES[@]} -eq 0 ]; then
  echo "Ошибка: В директории $CONFIG_DIR нет доступных конфигурационных файлов."
  exit 1
fi

# Вывод списка конфигурационных файлов
echo "Доступные конфигурации:"
for i in "${!CONFIG_FILES[@]}"; do
  echo "$((i + 1)). ${CONFIG_FILES[i]}"
done

# Запрос у пользователя выбора конфигурации
read -p "Введите номер конфигурации, которую вы хотите использовать: " CHOICE

# Проверка валидности выбора
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -le 0 ] || [ "$CHOICE" -gt ${#CONFIG_FILES[@]} ]; then
  echo "Ошибка: Неверный выбор. Завершение работы."
  exit 1
fi

# Получение выбранного файла
SELECTED_CONFIG="${CONFIG_FILES[$((CHOICE - 1))]}"

# Копирование выбранного файла в целевую директорию
cp "$CONFIG_DIR/$SELECTED_CONFIG" "$TARGET_CONFIG"

if [ $? -eq 0 ]; then
  echo "Конфигурация '$SELECTED_CONFIG' успешно применена."
else
  echo "Ошибка при применении конфигурации."
  exit 1
fi

if docker ps | grep -q "zapret-proxy"; then
  echo "Контейнер уже запущен. Остановка контейнера..."
  docker kill zapret-proxy
fi

# Запуск контейнера
echo "Запуск контейнера..."
docker-compose build
docker-compose up -d

if [ $? -eq 0 ]; then
  echo "Контейнер успешно запущен."
else
  echo "Ошибка при запуске контейнера."
  exit 1
fi
