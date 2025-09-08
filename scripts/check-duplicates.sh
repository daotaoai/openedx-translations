#!/bin/bash

# Script to check for duplicate msgid entries in .po files
# Usage: ./check-duplicates.sh [directory]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default directory is current directory
SEARCH_DIR="${1:-.}"

echo -e "${BLUE}🔍 Checking for duplicate msgid entries in .po files...${NC}"
echo -e "${BLUE}📂 Search directory: $SEARCH_DIR${NC}"
echo ""

duplicates_found=false
total_files=0
files_with_duplicates=0

# Function to check a single file
check_file() {
    local file="$1"
    echo -e "${BLUE}📄 Checking: $file${NC}"

    # Extract msgid lines with line numbers, sort by msgid content, find duplicates
    # Exclude empty msgids as they are normal in .po files
    local duplicates
    duplicates=$(grep -n "^msgid " "$file" 2>/dev/null | \
                grep -v '^[0-9]*:msgid ""$' | \
                sort -k2 | \
                uniq -f1 -D)

    if [ -n "$duplicates" ]; then
        echo -e "${RED}❌ Found duplicate msgid entries:${NC}"
        echo "$duplicates" | while read -r line; do
            echo "  $line"
        done
        echo ""

        # Extract unique msgid values that are duplicated
        local duplicate_msgids
        duplicate_msgids=$(echo "$duplicates" | \
                          cut -d':' -f2- | \
                          sort | \
                          uniq)

        echo -e "${YELLOW}📋 Unique duplicate msgid values:${NC}"
        echo "$duplicate_msgids" | while read -r msgid; do
            echo "  $msgid"
        done
        echo ""

        # Show context for each duplicate
        echo -e "${YELLOW}📍 Context for duplicates:${NC}"
        while IFS= read -r msgid_line; do
            if [ -n "$msgid_line" ]; then
                local msgid_content
                msgid_content=$(echo "$msgid_line" | sed 's/^msgid //')
                echo -e "${YELLOW}  🔍 Context for $msgid_content:${NC}"

                # Show context with line numbers
                grep -n -A3 -B3 "^msgid $msgid_content$" "$file" 2>/dev/null | \
                    sed 's/^/    /' || true
                echo ""
            fi
        done <<< "$duplicate_msgids"

        duplicates_found=true
        ((files_with_duplicates++))
    else
        echo -e "${GREEN}✅ No duplicates found${NC}"
    fi
    echo "---"
}

# Find and check all .po files
if [ -d "$SEARCH_DIR" ]; then
    while IFS= read -r -d '' file; do
        check_file "$file"
        ((total_files++))
    done < <(find "$SEARCH_DIR" -name "*.po" -type f -print0)
else
    echo -e "${RED}❌ Directory $SEARCH_DIR not found${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📊 SUMMARY${NC}"
echo "=========="
echo "Total .po files checked: $total_files"
echo "Files with duplicates: $files_with_duplicates"

if [ "$duplicates_found" = true ]; then
    echo -e "${RED}❌ DUPLICATE MESSAGES DETECTED!${NC}"
    echo ""
    echo -e "${YELLOW}💡 How to fix duplicates:${NC}"
    echo "1. Review the context of each duplicate msgid"
    echo "2. Check if they have different msgctxt (context) - if so, they are valid"
    echo "3. If they are true duplicates without different contexts:"
    echo "   - Keep the first occurrence"
    echo "   - Remove subsequent duplicate entries"
    echo "4. Ensure translations are consistent"
    echo ""
    echo -e "${YELLOW}📝 Example of valid duplicates (different context):${NC}"
    echo '   msgctxt "button"'
    echo '   msgid "Save"'
    echo '   msgstr "Lưu"'
    echo ""
    echo '   msgctxt "menu"'
    echo '   msgid "Save"'
    echo '   msgstr "Lưu"'
    echo ""
    exit 1
else
    echo -e "${GREEN}🎉 No duplicate msgid entries found!${NC}"
    exit 0
fi
