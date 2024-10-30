import textwrap

# Function to split a base64 string into smaller chunks
def split_base64_string(input_string, chunk_size=76):
    return textwrap.wrap(input_string, chunk_size)

# Read the base64 string from a file
def read_base64_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()

# Generate the C++ code to include in your header file
def generate_header_file(base64_string, output_path, variable_name):
    chunks = split_base64_string(base64_string)
    with open(output_path, 'w') as file:
        file.write("#ifndef DLL_BASE64_H\n")
        file.write("#define DLL_BASE64_H\n\n")
        file.write("#include <string>\n\n")
        file.write(f"const std::string {variable_name} =\n")
        
        for chunk in chunks:
            file.write(f'    "{chunk}"\n')
        
        file.write(";\n\n")
        file.write("#endif // DLL_BASE64_H\n")

def main():
    input_file_path = '/some/path/b64.txt'  # Replace with your input file path
    output_file_path = 'dll_base642.h'     # Replace with your output file path
    variable_name = 'libsodium'     # Replace with your desired variable name

    base64_string = read_base64_from_file(input_file_path)
    generate_header_file(base64_string, output_file_path, variable_name)
    print("Base64 string has been split and written to", output_file_path)

if __name__ == "__main__":
    main()
