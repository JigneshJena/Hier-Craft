import json
from collections import defaultdict

def count_questions(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    
    report = {}
    for domain, questions in data.items():
        counts = defaultdict(int)
        for q in questions:
            counts[q['difficulty']] += 1
        report[domain] = dict(counts)
    
    return report

if __name__ == "__main__":
    file_path = r"m:\Android_Projects\mockinterviewapp\assets\questions.json"
    counts = count_questions(file_path)
    print(json.dumps(counts, indent=2))
