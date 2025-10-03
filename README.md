# PDF Form Key Mapping Project

This project facilitates the creation of ERB form mapping files by extracting form field keys from PDFs and matching them with frontend JSON payloads.

## Project Structure

```
Key_Mapping/
├── input/                    # Drop input files here
│   ├── pdfs/                # Place PDF forms here
│   └── payloads/            # Place JSON payloads here
├── output/                   # Generated outputs
│   ├── extracted_keys/      # PDF field keys extracted by pdftk
│   └── form_mappings/       # Generated .erb mapping files
├── scripts/                  # Utility scripts
│   └── extract_pdf_keys.sh  # Extract form keys from PDFs
├── Example_form_mappings/    # Example .erb files for reference
├── CLAUDE.md                 # Instructions for Claude Code
└── CURSOR.md                 # Instructions for Cursor AI

```

## Prerequisites

- **pdftk** - Required for extracting PDF form field keys
  ```bash
  # Install on macOS
  brew install pdftk-java

  # Install on Ubuntu/Debian
  sudo apt-get install pdftk
  ```

## Quick Start

### 1. Add Your Files

1. **PDF Form**: Drop your PDF file into `input/pdfs/`
2. **JSON Payload**: Drop your frontend payload JSON into `input/payloads/`
   - Name it to match your PDF (e.g., `form1.pdf` → `form1.json`)

### 2. Extract PDF Form Keys

```bash
# Extract keys from a specific PDF
./scripts/extract_pdf_keys.sh form1.pdf

# Extract keys from all PDFs
./scripts/extract_pdf_keys.sh --all
```

The extracted keys will be saved to:
- `output/extracted_keys/{pdf_name}_keys.txt` - Full field data
- `output/extracted_keys/{pdf_name}_keys_names_only.txt` - Just the field names

### 3. Generate ERB Mapping

Use Claude Code or Cursor AI with the provided instructions to:
1. Read the PDF keys from `output/extracted_keys/`
2. Read the JSON payload from `input/payloads/`
3. Reference examples in `Example_form_mappings/`
4. Generate the .erb mapping file in `output/form_mappings/`

## File Naming Convention

For best results, use consistent naming:
- PDF: `input/pdfs/application_form.pdf`
- JSON: `input/payloads/application_form.json`
- Output: `output/form_mappings/application_form.erb`

## AI Agent Usage

### For Claude Code
See [CLAUDE.md](CLAUDE.md) for detailed instructions on using Claude Code to generate form mappings.

### For Cursor AI
See [CURSOR.md](CURSOR.md) for detailed instructions on using Cursor to generate form mappings.

## Example Workflow

1. Place `tax_form_2024.pdf` in `input/pdfs/`
2. Place `tax_form_2024.json` in `input/payloads/`
3. Run: `./scripts/extract_pdf_keys.sh tax_form_2024.pdf`
4. Open Claude Code or Cursor
5. Follow the agent-specific instructions to generate the mapping
6. Find your generated mapping in `output/form_mappings/tax_form_2024.erb`

## Troubleshooting

- **pdftk not found**: Install pdftk using the commands in Prerequisites
- **No form fields found**: The PDF may not have fillable form fields
- **Permission denied**: Run `chmod +x scripts/extract_pdf_keys.sh`
- **camelCase violations**: ERB templates must use snake_case, not camelCase from JSON payloads
  - Run validation: `ruby scripts/validate_snake_case.rb output/form_mappings/your_form.erb`
  - The vets-api backend automatically converts JSON keys from camelCase to snake_case
  - See [CLAUDE.md](CLAUDE.md) section 3.5 for conversion rules and examples