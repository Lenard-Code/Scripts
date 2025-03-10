import re
import subprocess

# Read the generated proxy code
with open("proxy.cpp", "r") as f:
    proxy_code = f.read()

# Path to the original DLL
original_dll = "C:\\Users\\C-PC3\\Desktop\\PingId.dll"

# Run dumpbin to get the list of exported functions
result = subprocess.run(["dumpbin", "/EXPORTS", original_dll], capture_output=True, text=True)

# Parse the output to extract function names and ordinals
lines = result.stdout.splitlines()
functions = {}
start_collecting = False

for line in lines:
    if "ordinal hint RVA      name" in line:
        start_collecting = True
        continue
    if start_collecting:
        parts = line.split()
        if len(parts) >= 4:
            ordinal = parts[0]
            name = parts[3]
            functions[name] = ordinal

# Add ordinals to the proxy code
def add_ordinals(match):
    func_name = match.group(1)
    if func_name in functions:
        ordinal = functions[func_name]
        return f'        p{func_name} = ({func_name}Type)GetProcAddress(hOriginalDll, (LPCSTR){ordinal}); // Using ordinal {ordinal}'
    return match.group(0)

proxy_code = re.sub(r'        p(\w+) = \(\1Type\)GetProcAddress\(hOriginalDll, "\1"\);', add_ordinals, proxy_code)

# Write the modified proxy code to a file
with open("proxy_with_ordinals.cpp", "w") as f:
    f.write(proxy_code)

print("Proxy code with ordinals generated in proxy_with_ordinals.cpp")