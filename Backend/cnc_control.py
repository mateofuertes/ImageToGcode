# cnc_control.py

import time
import serial
import threading

# CNC Machine setup
COM_PORTS = [f'COM{i}' for i in range(1, 51)]  # Extend range to COM50
s = None
stop_event = threading.Event()

def find_grbl_com_port(com_ports):
    for port in com_ports:
        try:
            s = serial.Serial(port, 115200)
            s.close()
            return port
        except (OSError, serial.SerialException):
            continue
    raise Exception("Could not find GRBL COM port")

def initialize_cnc():
    global s
    com_port = find_grbl_com_port(COM_PORTS)
    print(f'Found COM port: {com_port}')
    s = serial.Serial(com_port, 115200)
    time.sleep(2)
    s.flushInput()

def send_command(command, ser):
    if ser is None:
        raise Exception("Serial connection not established")
    ser.write((command + '\n').encode())
    response = ser.readline().decode().strip()
    print(f'{command} : {response}')
    return response

def move_spindle(axis, increment, direction, ser):
    if axis not in ['X', 'Y', 'Z']:
        raise ValueError("Axis must be X, Y, or Z")
    if direction not in ['+', '-']:
        raise ValueError("Direction must be '+' or '-'")
    gcode = f"G91\nG0 {axis}{direction}{increment}"
    send_command(gcode, ser)

def control_spindle(command, ser):
    if command == 'start':
        send_command('M3 S1000', ser)
    elif command == 'stop':
        send_command('M5', ser)
    elif command == 'set':
        send_command('G92 X0 Y0 Z0', ser)
    else:
        raise ValueError("Invalid command")

def execute_gcode_file(gcode_file_path, ser):
    if ser is None:
        raise Exception("Serial connection not established")
    with open(gcode_file_path, 'r') as file:
        for line in file:
            if stop_event.is_set():
                print("Safety stop triggered. Stopping execution.")
                safety_stop(ser)
                return
            command = line.strip()
            if command:
                send_command(command, ser)

def safety_stop(ser):
    """Raise the spindle to the maximum height for safety."""
    max_z_height = 20
    stop_commands = [
        "M5",
        "G90"
        f"G0 X0 Y0 Z{max_z_height}"
    ]
    for command in stop_commands:
        send_command(command, ser)
    stop_event.set()

def start_execution(gcode_file_path, ser):
    """Function to start G-code execution in a separate thread."""
    global stop_event
    stop_event.clear()
    threading.Thread(target=execute_gcode_file, args=(gcode_file_path, ser)).start()