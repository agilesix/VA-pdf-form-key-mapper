#!/bin/bash

# PDF Form Field Key Extractor
# This script uses pdftk to extract form field keys from PDFs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if pdftk is installed
if ! command -v pdftk &> /dev/null; then
    echo -e "${RED}Error: pdftk is not installed${NC}"
    echo "Install pdftk using: brew install pdftk-java"
    exit 1
fi

# Check arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <pdf_filename> OR $0 --all"
    echo ""
    echo "Options:"
    echo "  <pdf_filename>  Extract keys from a specific PDF in input/pdfs/"
    echo "  --all          Extract keys from all PDFs in input/pdfs/"
    echo ""
    echo "Examples:"
    echo "  $0 form1.pdf"
    echo "  $0 --all"
    exit 1
fi

# Function to extract keys from a single PDF
extract_keys() {
    local pdf_file="$1"
    local pdf_name=$(basename "$pdf_file" .pdf)
    local output_file="output/extracted_keys/${pdf_name}_keys.txt"

    echo -e "${YELLOW}Processing: ${pdf_file}${NC}"

    # Extract form field data
    if pdftk "$pdf_file" dump_data_fields > "$output_file" 2>/dev/null; then
        # Check if any fields were found
        if [ -s "$output_file" ]; then
            # Extract just the field names
            grep "^FieldName:" "$output_file" | sed 's/^FieldName: //' > "${output_file%.txt}_names_only.txt"

            echo -e "${GREEN}✓ Extracted keys saved to:${NC}"
            echo "  - Full data: $output_file"
            echo "  - Names only: ${output_file%.txt}_names_only.txt"

            # Show field count
            field_count=$(grep -c "^FieldName:" "$output_file")
            echo -e "${GREEN}  Found ${field_count} form fields${NC}"
        else
            echo -e "${YELLOW}⚠ No form fields found in $pdf_file${NC}"
            rm "$output_file"
        fi
    else
        echo -e "${RED}✗ Failed to process $pdf_file${NC}"
        rm -f "$output_file"
        return 1
    fi
}

# Main logic
if [ "$1" == "--all" ]; then
    # Process all PDFs
    echo -e "${GREEN}Extracting keys from all PDFs in input/pdfs/${NC}"
    echo ""

    pdf_count=0
    for pdf_file in input/pdfs/*.pdf; do
        if [ -f "$pdf_file" ]; then
            extract_keys "$pdf_file"
            echo ""
            ((pdf_count++))
        fi
    done

    if [ $pdf_count -eq 0 ]; then
        echo -e "${YELLOW}No PDF files found in input/pdfs/${NC}"
        exit 1
    else
        echo -e "${GREEN}Processed ${pdf_count} PDF file(s)${NC}"
    fi
else
    # Process single PDF
    pdf_file="input/pdfs/$1"

    if [ ! -f "$pdf_file" ]; then
        echo -e "${RED}Error: File not found: $pdf_file${NC}"
        echo "Make sure the PDF file is in the input/pdfs/ directory"
        exit 1
    fi

    extract_keys "$pdf_file"
fi