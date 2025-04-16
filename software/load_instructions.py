import serial
import time
import sys

# UART Configuration
UART_PORT = '/dev/ttyUSB2'     # Update to your port
UART_BAUDRATE = 9600
UART_DELAY = 10 / UART_BAUDRATE  # 10-bit frame per byte = start + 8 data + stop

# Open serial port
ser = serial.Serial(
    port=UART_PORT,
    baudrate=UART_BAUDRATE,
    timeout=1
)

def send_hex_instruction(instr_hex):
    """
    Sends a 32-bit instruction over UART, little-endian, one byte at a time.
    instr_hex: string like '0x00500093' or '00500093'
    """
    try:
        instr_int = int(instr_hex, 16)
        bytes_le = instr_int.to_bytes(4, byteorder='little')
        for b in bytes_le:
            ser.write(bytes([b]))
            time.sleep(UART_DELAY)  # optional: wait between bytes
        print(f"Sent: {instr_hex} as {[hex(b) for b in bytes_le]}")
    except ValueError:
        print(f"Invalid hex instruction: {instr_hex}")

def send_from_file(file_path):
    with open(file_path, 'r') as f:
        for line in f:
            clean_line = line.strip()
            if clean_line and not clean_line.startswith("#"):
                send_hex_instruction(clean_line)

def interactive_mode():
    while True:
        user_input = input("Enter hex instruction (or 'exit' to quit): ")
        if user_input.lower() == 'exit':
            break
        send_hex_instruction(user_input)

if __name__ == "__main__":
    try:
        if len(sys.argv) == 2:
            send_from_file(sys.argv[1])
        else:
            print("No input file specified. Starting interactive mode...")
            interactive_mode()
    except KeyboardInterrupt:
        print("\nInterrupted by user.")
    finally:
        ser.close()
        print("Serial port closed.")
