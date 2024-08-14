import time
import serial
import threading

# Global variable for stop event
stop_event = threading.Event()

def send_command(command, ser):
    """
    Sends a command to the CNC machine via the specified serial connection and reads the response.

    Parameters:
    - command (str): The G-code or command to send to the CNC machine.
    - ser (serial.Serial): The serial connection to the CNC machine.

    Returns:
    - str: The response from the CNC machine.

    Raises:
    - Exception: If the serial connection is not established.
    """
    if ser is None:
        raise Exception("Serial connection not established")
    ser.write((command + '\n').encode())
    response = ser.readline().decode().strip()
    print(f'{command} : {response}')
    return response

def move_spindle(axis, increment, direction, ser):
    """
    Moves the spindle along the specified axis by a given increment in the specified direction.

    Parameters:
    - axis (str): The axis to move ('X', 'Y', or 'Z').
    - increment (float): The amount to move the spindle.
    - direction (str): The direction to move ('+' or '-').
    - ser (serial.Serial): The serial connection to the CNC machine.

    Raises:
    - ValueError: If the axis or direction is invalid.
    """
    if axis not in ['X', 'Y', 'Z']:
        raise ValueError("Axis must be X, Y, or Z")
    if direction not in ['+', '-']:
        raise ValueError("Direction must be '+' or '-'")
    gcode = f"G91\nG0 {axis}{direction}{increment}"
    send_command(gcode, ser)

def control_spindle(command, ser):
    """
    Controls the spindle based on the provided command. Commands include starting, stopping, and setting position.

    Parameters:
    - command (str): The command to execute ('start', 'stop', or 'set').
    - ser (serial.Serial): The serial connection to the CNC machine.

    Raises:
    - ValueError: If the command is invalid.
    """
    if command == 'start':
        send_command('M3 S1000', ser)
    elif command == 'stop':
        send_command('M5', ser)
    elif command == 'set':
        send_command('G92 X0 Y0 Z0', ser)
    else:
        raise ValueError("Invalid command")

def execute_gcode_file(gcode_file_path, ser):
    """
    Executes G-code commands from a file, stopping execution if a stop event is triggered.

    Parameters:
    - gcode_file_path (str): The path to the file containing G-code commands.
    - ser (serial.Serial): The serial connection to the CNC machine.

    Raises:
    - Exception: If the serial connection is not established.
    """
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
    """
    Raises the spindle to a safe height and stops all CNC operations. Sets a stop event to prevent further actions.

    Parameters:
    - ser (serial.Serial): The serial connection to the CNC machine.
    """
    max_z_height = 20
    stop_commands = [
        "M5", # Stop spindle
        "G90" # Set absolute positioning
        f"G0 X0 Y0 Z{max_z_height}" # Move to the safe height
    ]
    for command in stop_commands:
        send_command(command, ser)
    stop_event.set()

def start_execution(gcode_file_path, ser):
    """
    Starts G-code execution in a separate thread to avoid blocking the main thread.

    Parameters:
    - gcode_file_path (str): The path to the file containing G-code commands.
    - ser (serial.Serial): The serial connection to the CNC machine.
    """
    global stop_event
    stop_event.clear()
    threading.Thread(target=execute_gcode_file, args=(gcode_file_path, ser)).start()
