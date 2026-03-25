#!/usr/bin/env python3
import json, os, subprocess, sys

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

def get_json(cmd):
    out = run(cmd)
    return json.loads(out) if out.strip() else {}

def clip(s, n=200):
    s = s.replace('\r\n','\n').replace('\r','\n').strip()
    return (s[:n] + '…') if len(s) > n else s

# Load env
env_path = "/home/ubuntu/.openclaw/workspace/skills/gog/.env"
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            if line.strip().startswith('#') or '=' not in line:
                continue
            k,v = line.strip().split('=',1)
            os.environ[k]=v

# Search inbox (last 10 minutes)
search_cmd = 'gog gmail search "in:inbox newer_than:10m" --max 20 --json --no-input'
spam_cmd = 'gog gmail search "in:spam newer_than:7d" --max 20 --json --no-input'

try:
    inbox = get_json(search_cmd)
except subprocess.CalledProcessError as e:
    print("Không đọc được Gmail (lỗi khi search inbox).")
    sys.exit(0)

threads = inbox.get('threads', []) or []

# Count categories
important_count = 0
promo_social_count = 0

items = []
for t in threads:
    labels = t.get('labels', []) or []
    subj = t.get('subject','') or '(không tiêu đề)'
    frm = t.get('from','') or '(không rõ người gửi)'
    if 'IMPORTANT' in labels or 'CATEGORY_UPDATES' in labels:
        important_count += 1
    if 'CATEGORY_PROMOTIONS' in labels or 'CATEGORY_SOCIAL' in labels:
        promo_social_count += 1

    # fetch body
    tid = t.get('id')
    body = ''
    if tid:
        try:
            detail = get_json(f"gog gmail get {tid} --json --no-input")
            body = detail.get('body','') or detail.get('snippet','') or ''
        except Exception:
            body = t.get('snippet','') or ''
    items.append((frm, subj, clip(body)))

# Spam count
try:
    spam = get_json(spam_cmd)
    spam_count = len(spam.get('threads', []) or [])
except Exception:
    spam_count = 0

if not items:
    print("Không có email mới.")
    sys.exit(0)

print("Email mới (10 phút gần đây):")
for frm, subj, body in items:
    print(f"- {frm} — \"{subj}\"\n  Nội dung: {body}")

print("\nPhân loại:")
print(f"- Important/Security: {important_count}")
print(f"- Promos/Social: {promo_social_count}")
print(f"- Spam (7 ngày): {spam_count}")
