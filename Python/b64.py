import base64

# Read the configuration file
with open('/some/path/file.dll', 'rb') as file:
    config_content = file.read()

# Encode the content to a base64 string
base64_encoded = base64.b64encode(config_content).decode('utf-8')

# Print the base64 string
print(base64_encoded)
