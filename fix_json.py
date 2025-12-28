import json

def fix_json(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()
    
    # We know the first occurrence of '"Pharmacy": [' is wrong and it is nested.
    # It starts around character 17933 as per the error message.
    
    search_str = '"Pharmacy": ['
    idx = content.find(search_str)
    if idx == -1:
        print("Could not find Pharmacy key")
        return
    
    # We want to remove this block. 
    # But wait, it might be more complex than just finding the next ']'.
    # It has nested objects.
    
    # Let's find the closing bracket for this array.
    depth = 0
    end_idx = -1
    for i in range(idx + len(search_str) - 1, len(content)):
        if content[i] == '[':
            depth += 1
        elif content[i] == ']':
            depth -= 1
            if depth == 0:
                end_idx = i + 1
                break
    
    if end_idx != -1:
        # Also remove the trailing comma if there is one
        if content[end_idx] == ',':
            end_idx += 1
        
        # We need to make sure we don't leave a trailing comma where it shouldn't be
        # or remove one where it should be.
        # Line 856 has a comma after the previous object.
        
        # Let's see the context.
        print(f"Removing content from {idx} to {end_idx}")
        new_content = content[:idx] + content[end_idx:]
        
        # Check if we left a trailing comma at the end of the previous object
        # which might be the last object now.
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Successfully fixed JSON.")
    else:
        print("Could not find end of Pharmacy block")

if __name__ == "__main__":
    file_path = r"m:\Android_Projects\mockinterviewapp\assets\questions.json"
    fix_json(file_path)
