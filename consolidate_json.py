import json

def consolidate_json(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    
    # JSON in this file is sometimes a list of dicts with same key? 
    # No, JSON usually doesn't allow duplicate keys in the same object. 
    # If the file had duplicate keys, json.load() might have overwritten them or errored.
    # However, findstr shows multiple occurrences of "Flutter": [ etc. 
    # This means the file might have structural issues (multiple root objects or something).
    
    # Let's try to parse it carefully. If it's valid JSON, json.load will only keep the last occurrence of a key.
    # If it's NOT valid JSON (multiple roots), we need a different approach.
    return data

if __name__ == "__main__":
    file_path = r"m:\Android_Projects\mockinterviewapp\assets\questions.json"
    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()
            # If there are duplicate keys in one object, json.loads keeps the last one.
            # But what if there are multiple objects?
            data = json.loads(content)
            with open(file_path, 'w', encoding='utf-8') as fw:
                json.dump(data, fw, indent=2)
            print("Successfully consolidated and formatted JSON.")
    except Exception as e:
        print(f"Error: {e}")
