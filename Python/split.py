import os

# Read the binary file
with open('/path/to/binary/file/applicaiton.exe', 'rb') as f:
    data = f.read()

# Set the size of each part
part_size = 1024
num_parts = (len(data) + part_size - 1) // part_size  # Calculate the number of parts

# Create the output header file
with open('/mnt/application_data.h', 'w') as h_file:
    h_file.write('// Generated file: applicaiton_data.h\n\n')
    
    for i in range(num_parts):
        # Get the part of the data
        part = data[i * part_size: (i + 1) * part_size]
        
        # Create a hex representation of the part
        hex_values = ', '.join(f'0x{byte:02x}' for byte in part)
        h_file.write(f'unsigned char application_data_part{i + 1}[] = {{ {hex_values} }};\n')
        h_file.write(f'unsigned int application_data_part{i + 1}_len = sizeof(applicaiton_data_part{i + 1});\n\n')
