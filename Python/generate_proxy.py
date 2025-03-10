import subprocess

# Path to the original DLL
original_dll = "C:\\Users\\C-PC3\\Desktop\\PingId.dll"

# Run dumpbin to get the list of exported functions
result = subprocess.run(["dumpbin", "/EXPORTS", original_dll], capture_output=True, text=True)

# Parse the output to extract function names and ordinals
lines = result.stdout.splitlines()
functions = []
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
            functions.append((ordinal, name))

# Generate the proxy code
proxy_code = """
#include <windows.h>

// Handles for the original DLL and the functions
HMODULE hOriginalDll = NULL;

void LoadOriginalDll()
{
    if (hOriginalDll == NULL)
    {
        // Load the original DLL
        hOriginalDll = LoadLibrary(L"C:\\Windows\\System32\\PingIdCredentialProvider.dll");
    }
}
"""

# Generate function forwarders
for ordinal, name in functions:
    proxy_code += f"""
typedef void (*{name}Type)();
{name}Type p{name} = NULL;

extern "C" __declspec(dllexport) void {name}()
{{
    if (!p{name})
    {{
        LoadOriginalDll();
        p{name} = ({name}Type)GetProcAddress(hOriginalDll, "{name}");
    }}
    if (p{name})
    {{
        p{name}();
    }}
    else
    {{
        MessageBox(NULL, L"{name} not found in Test2.dll", L"Error", MB_OK);
    }}
}}
"""

# Generate DllMain
proxy_code += """
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    switch (fdwReason)
    {
    case DLL_PROCESS_ATTACH:
        LoadOriginalDll();
        break;

    case DLL_PROCESS_DETACH:
        if (hOriginalDll)
        {
            FreeLibrary(hOriginalDll);
            hOriginalDll = NULL;
        }
        break;
    }
    return TRUE;
}
"""

# Write the proxy code to a file
with open("proxy.cpp", "w") as f:
    f.write(proxy_code)

print("Proxy code generated in proxy.cpp")