import os
import random
import string

# Define the folder name and file types
folder_name = 'random_office_files'
file_types = ['.docx', '.csv', '.xlsx', '.txt', '.pdf', '.pptx']

# Define a list of typical office file names
file_names = [
    'contacts', 'CustomerData', 'mypasswords', 'socialmedia', 'report', 'notes', 'budget',
    'project_plan', 'meeting_minutes', 'invoice', 'presentation', 'resume', 'contract',
    'proposal', 'strategy', 'analysis', 'summary', 'agenda', 'log', 'timesheet', 'schedule',
    'tasks', 'goals', 'ideas', 'journal', 'research', 'reference', 'performance', 'assessment'
]

# Create the folder
if not os.path.exists(folder_name):
    os.makedirs(folder_name)

# Function to generate random string
def random_string(length=6):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

# Function to generate random data
def generate_random_data(size_kb):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=size_kb * 1024))

# Create files in the folder
for i in range(30):
    file_name = random.choice(file_names)
    file_type = random.choice(file_types)
    if 'passwords' in file_name or 'pass' in file_name or random.random() < 0.1:
        file_name += '_pass'
    file_name += '_' + random_string() + file_type
    file_path = os.path.join(folder_name, file_name)
    with open(file_path, 'w') as f:
        if random.random() < 0.5:  # 50% chance to fill the file with random data
            f.write(generate_random_data(random.randint(1, 10)))  # Up to 10 KB
        else:
            f.write("This is a sample content for file: " + file_name)

print(f"Created {len(os.listdir(folder_name))} files in the folder '{folder_name}'.")