#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-}"
if [[ -z "$PORT" ]]; then
  PORT=$(ls /dev/cu.usbserial-* /dev/cu.SLAB_USBtoUART /dev/cu.wchusbserial* /dev/cu.usbmodem* 2>/dev/null | head -1 || true)
fi
if [[ -z "$PORT" || ! -e "$PORT" ]]; then
  echo "Не найден serial-порт ESP32. Подключите USB-UART и передайте порт: ./flash.sh /dev/cu.usbserial-XXXX" >&2
  exit 2
fi
ESPTOOL="${ESPTOOL:-python3 -m esptool}"
if [[ "${ERASE:-0}" == "1" ]]; then
  eval "$ESPTOOL --chip esp32 --port '$PORT' erase_flash"
fi
eval "$ESPTOOL --chip esp32 --port '$PORT' --baud 460800 write_flash --flash_mode dio --flash_freq 40m --flash_size detect \\
  0x1000 firmware/bootloader.bin \\
  0x8000 firmware/partition-table.bin \\
  0xf000 firmware/ota_data_initial.bin \\
  0x20000 firmware/esp32_eth_router.bin"
echo "Готово. Подключитесь к Ethernet и откройте http://192.168.4.1"
