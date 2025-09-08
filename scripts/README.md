# Duplicate Message Checker for PO Files

Local tool to detect duplicate `msgid` entries in `.po` (gettext) translation files.

## 🚀 Features

- **Local Script**: Manual checking and validation with colored output
- **Detailed Reports**: Context analysis and fix suggestions
- **Easy to use**: Simple command-line interface

## 📁 Files Overview

### Scripts
- `scripts/check-duplicates.sh` - Local duplicate checking script

## 🔧 Setup

### Local Script Usage

```bash
# Check current directory
./scripts/check-duplicates.sh

# Check specific directory
./scripts/check-duplicates.sh /path/to/translations

# Make script executable if needed
chmod +x scripts/check-duplicates.sh
```

## 🔍 What Gets Checked

### Valid Cases (No Error)
```po
# Different contexts - OK
msgctxt "button"
msgid "Save"
msgstr "Lưu"

msgctxt "menu"
msgid "Save"
msgstr "Lưu"

# Empty msgids - OK (normal in .po files)
msgid ""
msgstr ""
```

### Invalid Cases (Error)
```po
# True duplicates - ERROR
msgid "Save"
msgstr "Lưu"

msgid "Save"  # ❌ Duplicate without different context
msgstr "Lưu"
```

## 📊 Understanding the Output

### Local Script Output
```bash
📄 Checking: ./translations/vi/django.po
❌ Found duplicate msgid entries:
  1234:msgid "Save"
  5678:msgid "Save"

📋 Unique duplicate msgid values:
  msgid "Save"

📍 Context for duplicates:
  🔍 Context for msgid "Save":
    1232-#: button.py:10
    1233-msgid "Save"
    1234:msgstr "Lưu"
    --
    5676-#: menu.py:20
    5677-msgid "Save"
    5678:msgstr "Lưu"
```

## 🛠️ Fixing Duplicates

### Method 1: Remove True Duplicates
If msgids are identical without different contexts:
```bash
# Keep the first occurrence, remove subsequent ones
# Manual editing or use sed/awk
```

### Method 2: Add Context for Valid Duplicates
If the same text appears in different contexts:
```po
# Before (invalid)
msgid "Save"
msgstr "Lưu"

msgid "Save"
msgstr "Lưu"

# After (valid)
msgctxt "button"
msgid "Save"
msgstr "Lưu"

msgctxt "menu"
msgid "Save"
msgstr "Lưu"
```

### Method 3: Merge Translations
If duplicates have the same context, merge them:
```po
# Before
#: file1.py:10
msgid "Hello"
msgstr "Xin chào"

#: file2.py:20
msgid "Hello"
msgstr "Xin chào"

# After
#: file1.py:10 file2.py:20
msgid "Hello"
msgstr "Xin chào"
```

## 🚫 Bypassing Checks (Not Recommended)

### Local Script
```bash
# The script always exits with error code if duplicates found
# You can ignore the exit code:
./scripts/check-duplicates.sh || echo "Ignoring duplicates"
```

## 🔧 Customization

### Customize Script Behavior
Edit `scripts/check-duplicates.sh` to:
- Change output colors
- Modify search patterns
- Add different file extensions
- Change error handling

## 🐛 Troubleshooting

### "No .po files found"
- Check if you're in the right directory
- Ensure .po files exist in the search path
- Check file permissions

### "Permission denied"
```bash
chmod +x scripts/check-duplicates.sh
```

### "False positives"
- Review if duplicates have different `msgctxt`
- Check if they're genuinely different contexts
- Consider adding appropriate contexts

## 📝 Contributing

1. Test any changes with the local script first
2. Update this README if adding new features
3. Test with real .po files from the project

## 📚 References

- [GNU gettext Manual](https://www.gnu.org/software/gettext/manual/)
- [PO File Format](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html)
