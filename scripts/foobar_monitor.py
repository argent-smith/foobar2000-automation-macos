#!/usr/bin/env python3
"""
foobar2000 Directory Monitor for macOS
Отслеживает папку ~/Music/Import и автоматически добавляет новые аудиофайлы в foobar2000
"""

import os
import sys
import time
import subprocess
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import logging
from datetime import datetime

# Конфигурация
IMPORT_DIR = Path.home() / "Music" / "Import"
LOG_DIR = Path.home() / "Library" / "foobar2000-v2" / "logs"
LOG_FILE = LOG_DIR / "monitor.log"

# Поддерживаемые аудиоформаты
AUDIO_EXTENSIONS = {'.flac', '.mp3', '.wav', '.m4a', '.aac', '.opus', '.ogg', '.wma'}

# Создание директорий
IMPORT_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Настройка логгирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

class AudioFileHandler(FileSystemEventHandler):
    """Обработчик событий файловой системы для аудиофайлов"""
    
    def __init__(self):
        self.processed_files = set()
        
    def on_created(self, event):
        """Обработка создания новых файлов"""
        if event.is_directory:
            return
            
        self.process_file(event.src_path)
    
    def on_moved(self, event):
        """Обработка перемещения файлов"""
        if event.is_directory:
            return
            
        self.process_file(event.dest_path)
    
    def process_file(self, file_path):
        """Обработка аудиофайла"""
        try:
            path = Path(file_path)
            
            # Проверка расширения
            if path.suffix.lower() not in AUDIO_EXTENSIONS:
                return
            
            # Проверка, что файл уже не обрабатывался
            if str(path) in self.processed_files:
                return
                
            # Ожидание завершения записи файла
            self.wait_for_file_complete(path)
            
            if path.exists() and path.is_file():
                logger.info(f"Обнаружен новый аудиофайл: {path.name}")
                
                # Добавление в foobar2000
                if self.add_to_foobar2000(path):
                    logger.info(f"✓ Успешно добавлен в foobar2000: {path.name}")
                    self.processed_files.add(str(path))
                else:
                    logger.error(f"✗ Ошибка добавления в foobar2000: {path.name}")
                
        except Exception as e:
            logger.error(f"Ошибка обработки файла {file_path}: {e}")
    
    def wait_for_file_complete(self, file_path, timeout=30):
        """Ожидание завершения записи файла"""
        previous_size = -1
        stable_time = 0
        check_interval = 1
        
        while stable_time < 3:  # Ждем 3 секунды стабильного размера
            if not file_path.exists():
                time.sleep(check_interval)
                continue
                
            try:
                current_size = file_path.stat().st_size
                
                if current_size == previous_size:
                    stable_time += check_interval
                else:
                    stable_time = 0
                    previous_size = current_size
                
                time.sleep(check_interval)
                timeout -= check_interval
                
                if timeout <= 0:
                    logger.warning(f"Таймаут ожидания завершения записи: {file_path.name}")
                    break
                    
            except (OSError, IOError) as e:
                logger.warning(f"Ошибка проверки файла {file_path.name}: {e}")
                time.sleep(check_interval)
                timeout -= check_interval
                
                if timeout <= 0:
                    break
    
    def add_to_foobar2000(self, file_path):
        """Добавление файла в foobar2000 через AppleScript"""
        try:
            applescript_cmd = f'''
            tell application "foobar2000"
                open POSIX file "{file_path}"
            end tell
            '''
            
            result = subprocess.run(
                ['osascript', '-e', applescript_cmd],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            return result.returncode == 0
            
        except subprocess.TimeoutExpired:
            logger.error(f"Таймаут при добавлении файла в foobar2000: {file_path.name}")
            return False
        except Exception as e:
            logger.error(f"Ошибка AppleScript при добавлении {file_path.name}: {e}")
            return False

def check_foobar2000_running():
    """Проверка, что foobar2000 запущен"""
    try:
        result = subprocess.run(
            ['pgrep', '-f', 'foobar2000'],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except Exception:
        return False

def monitor_directory():
    """Главная функция мониторинга"""
    logger.info(f"=== Запуск мониторинга foobar2000 ===")
    logger.info(f"Отслеживаемая папка: {IMPORT_DIR}")
    logger.info(f"Поддерживаемые форматы: {', '.join(sorted(AUDIO_EXTENSIONS))}")
    logger.info(f"Лог файл: {LOG_FILE}")
    
    if not IMPORT_DIR.exists():
        logger.error(f"Папка не найдена: {IMPORT_DIR}")
        sys.exit(1)
    
    # Проверка foobar2000
    if not check_foobar2000_running():
        logger.warning("foobar2000 не запущен, но мониторинг продолжается")
        logger.info("Файлы будут добавлены при запуске foobar2000")
    else:
        logger.info("foobar2000 обнаружен и запущен")
    
    # Создание обработчика и наблюдателя
    event_handler = AudioFileHandler()
    observer = Observer()
    observer.schedule(event_handler, str(IMPORT_DIR), recursive=True)
    
    try:
        # Запуск мониторинга
        observer.start()
        logger.info("✓ Мониторинг запущен. Нажмите Ctrl+C для остановки.")
        
        # Обработка существующих файлов при запуске
        logger.info("Проверка существующих файлов в папке...")
        for file_path in IMPORT_DIR.rglob('*'):
            if file_path.is_file() and file_path.suffix.lower() in AUDIO_EXTENSIONS:
                logger.info(f"Найден существующий файл: {file_path.name}")
                event_handler.process_file(str(file_path))
        
        # Основной цикл мониторинга
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        logger.info("Получен сигнал прерывания...")
    except Exception as e:
        logger.error(f"Критическая ошибка: {e}")
    finally:
        observer.stop()
        observer.join()
        logger.info("=== Мониторинг остановлен ===")

def print_status():
    """Печать статуса мониторинга"""
    print("\n" + "="*50)
    print("foobar2000 Directory Monitor для macOS")
    print("="*50)
    print(f"Папка мониторинга: {IMPORT_DIR}")
    print(f"Лог файл: {LOG_FILE}")
    print(f"Поддерживаемые форматы: {', '.join(sorted(AUDIO_EXTENSIONS))}")
    print(f"foobar2000 запущен: {'✓' if check_foobar2000_running() else '✗'}")
    print("="*50)

if __name__ == "__main__":
    try:
        print_status()
        
        # Установка зависимости если нужно
        try:
            import watchdog
        except ImportError:
            print("\n❌ Модуль watchdog не установлен")
            print("Установите командой: pip3 install --user watchdog")
            sys.exit(1)
        
        monitor_directory()
        
    except KeyboardInterrupt:
        print("\n\n👋 До свидания!")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Неожиданная ошибка: {e}")
        sys.exit(1)