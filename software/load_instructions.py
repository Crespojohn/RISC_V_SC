import serial
import time

# Set up the serial port (change COM3 to your port, e.g., /dev/ttyUSB0 on Linux/Mac)
ser = serial.Serial(
    port='/dev/ttyUSB2',        # Change this to your serial port
    baudrate=9600,      # Match the baud rate with your UART device
    timeout=1
)

def send_uart_data():
    try:
        while True:
            user_input = input("Enter a message to send over UART (type 'exit' to quit): ")
            if user_input.lower() == 'exit':
                print("Exiting...")
                break
            ser.write((user_input).encode())  # Send data over UART
            print(f"Sent: {user_input}")
    except KeyboardInterrupt:
        print("\nProgram interrupted.")
    finally:
        ser.close()
        print("Serial port closed.")

if __name__ == "__main__":
    send_uart_data()
