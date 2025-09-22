# Complete Workflow Example

This document walks through a complete example of processing a form from PDF to ERB mapping.

## Example: Processing a Tax Form

### Step 1: Prepare Your Files

Place your files in the correct directories:

```bash
# Place the PDF form
cp ~/Downloads/tax_form_2024.pdf input/pdfs/

# Place the JSON payload
cp ~/Downloads/tax_form_2024.json input/payloads/
```

### Step 2: Extract PDF Field Keys

Run the extraction script:

```bash
./scripts/extract_pdf_keys.sh tax_form_2024.pdf
```

Output:
```
Processing: input/pdfs/tax_form_2024.pdf
✓ Extracted keys saved to:
  - Full data: output/extracted_keys/tax_form_2024_keys.txt
  - Names only: output/extracted_keys/tax_form_2024_keys_names_only.txt
  Found 47 form fields
```

### Step 3: Verify Extracted Keys

Check what was extracted:

```bash
# View just the field names
cat output/extracted_keys/tax_form_2024_keys_names_only.txt

# Sample output:
# FirstName
# LastName
# SSN
# FilingStatus
# SpouseName
# DependentName1
# DependentSSN1
# ...
```

### Step 4: Review JSON Payload Structure

```bash
cat input/payloads/tax_form_2024.json

# Sample structure:
# {
#   "taxpayer": {
#     "first_name": "John",
#     "last_name": "Doe",
#     "ssn": "123-45-6789",
#     "filing_status": "married_filing_jointly"
#   },
#   "spouse": {
#     "first_name": "Jane",
#     "last_name": "Doe",
#     "ssn": "987-65-4321"
#   },
#   "dependents": [
#     {
#       "name": "Jack Doe",
#       "ssn": "111-22-3333",
#       "relationship": "son"
#     }
#   ]
# }
```

### Step 5: Use AI Agent to Generate Mapping

#### Option A: Using Claude Code

1. Open terminal in the project directory
2. Run: `claude`
3. Give this prompt:

```
Please create an ERB form mapping for tax_form_2024.
- The PDF field names are in output/extracted_keys/tax_form_2024_keys_names_only.txt
- The JSON payload is in input/payloads/tax_form_2024.json
- Reference the examples in Example_form_mappings/
- Save the result to output/form_mappings/tax_form_2024.erb
```

#### Option B: Using Cursor

1. Open the project in Cursor
2. Open the relevant files in tabs:
   - `output/extracted_keys/tax_form_2024_keys_names_only.txt`
   - `input/payloads/tax_form_2024.json`
   - An example from `Example_form_mappings/`
3. Create new file: `output/form_mappings/tax_form_2024.erb`
4. Use Cursor's AI to help generate the mappings

### Step 6: Verify the Generated Mapping

The AI should produce something like:

```erb
<%# Form: Tax Form 2024 %>
<%# Generated: 2024-01-15 %>
<%# Maps taxpayer JSON data to IRS PDF form fields %>

<%# Taxpayer Information %>
<%= pdf_field "FirstName", json_data.dig("taxpayer", "first_name") %>
<%= pdf_field "LastName", json_data.dig("taxpayer", "last_name") %>
<%= pdf_field "SSN", json_data.dig("taxpayer", "ssn").gsub("-", "") %>

<%# Filing Status %>
<% case json_data.dig("taxpayer", "filing_status") %>
<% when "single" %>
  <%= pdf_field "FilingStatus", "1" %>
<% when "married_filing_jointly" %>
  <%= pdf_field "FilingStatus", "2" %>
<% when "married_filing_separately" %>
  <%= pdf_field "FilingStatus", "3" %>
<% end %>

<%# Spouse Information (if applicable) %>
<% if json_data["spouse"].present? %>
  <%= pdf_field "SpouseName", "#{json_data.dig("spouse", "first_name")} #{json_data.dig("spouse", "last_name")}" %>
  <%= pdf_field "SpouseSSN", json_data.dig("spouse", "ssn").gsub("-", "") %>
<% end %>

<%# Dependents %>
<% (json_data["dependents"] || []).each_with_index do |dependent, index| %>
  <% break if index >= 4 %> <%# PDF only has 4 dependent fields %>
  <%= pdf_field "DependentName#{index + 1}", dependent["name"] %>
  <%= pdf_field "DependentSSN#{index + 1}", dependent["ssn"].gsub("-", "") %>
  <%= pdf_field "DependentRelationship#{index + 1}", dependent["relationship"] %>
<% end %>
```

### Step 7: Test and Refine

1. Review the generated ERB file
2. Check that all PDF fields are mapped
3. Verify data transformations are correct
4. Add any missing mappings or TODO comments

## Batch Processing

To process multiple forms at once:

```bash
# 1. Place all PDFs and JSONs
ls input/pdfs/
# form1.pdf  form2.pdf  form3.pdf

ls input/payloads/
# form1.json  form2.json  form3.json

# 2. Extract all keys
./scripts/extract_pdf_keys.sh --all

# 3. Use AI agent with a batch prompt:
# "Please generate ERB mappings for all forms that have both
#  extracted keys and JSON payloads available"
```

## Validation Checklist

Before considering a mapping complete:

- [ ] PDF file processed successfully
- [ ] JSON payload is valid and complete
- [ ] All PDF fields have mappings or TODOs
- [ ] Data transformations are tested
- [ ] ERB syntax is valid
- [ ] File saved in correct location
- [ ] Complex logic is documented

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| PDF has no form fields | Ensure PDF is fillable, not just a scanned document |
| Field names don't match | Create a mapping table in comments |
| Nested JSON too deep | Use `dig()` method with multiple parameters |
| Array sizes don't match | Add bounds checking in ERB |
| Special characters in data | Add sanitization/escaping methods |

## Next Steps

Once you have your ERB mapping file:

1. Test it with actual data
2. Integrate it into your application's PDF generation pipeline
3. Add validation and error handling as needed
4. Document any custom transformations

## Getting Help

- Check `CLAUDE.md` for Claude-specific instructions
- Check `CURSOR.md` for Cursor-specific instructions
- Review `Example_form_mappings/` for more patterns
- Verify PDFtk installation if extraction fails