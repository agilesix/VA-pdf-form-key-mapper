# Complete Workflow Example with Quality Assurance

This document walks through a complete example of processing a form from PDF to ERB mapping, with emphasis on proper QA procedures.

## ⚠️ Critical Lesson Learned

**PDF field names are misleading!** The field `VeteransLastName[0]` might actually be for spouse's name, email, or something else entirely. Always check `FieldNameAlt` descriptions in the extracted keys file.

## Complete Workflow: Processing a Tax Form

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

### Step 3: CRITICAL - Review the PDF Visually

**DO NOT SKIP THIS STEP!**

```bash
# Open the PDF to understand the form
open input/pdfs/tax_form_2024.pdf
```

Look for:
- Form sections and their order
- Conditional fields ("If yes, complete section...")
- Field relationships
- Required vs optional fields

### Step 4: Examine Extracted Keys with FieldNameAlt

**This is the most important step for accurate mapping:**

```bash
# View the complete extraction with field descriptions
cat output/extracted_keys/tax_form_2024_keys.txt

# Focus on FieldNameAlt descriptions
grep -B2 -A2 "FieldNameAlt" output/extracted_keys/tax_form_2024_keys.txt
```

Example discovery:
```
FieldName: form1[0].Page2[0].VeteransLastName[0]
FieldNameAlt: 1C. NAME OF SPOUSE. Enter Last Name.
---
FieldName: form1[0].Page2[0].VeteransLastName[1]
FieldNameAlt: 4. E-MAIL ADDRESS.
---
FieldName: form1[0].Page2[0].DOBmonth[1]
FieldNameAlt: 1G. WHAT WAS YOUR AGE AT THE TIME OF YOUR MARRIAGE?
```

### Step 5: Review JSON Payload Structure

```bash
# Pretty print the JSON
cat input/payloads/tax_form_2024.json | python -m json.tool

# Or with jq for better visualization
jq . input/payloads/tax_form_2024.json
```

### Step 6: Use AI Agent to Generate Initial Mapping

#### Option A: Using Claude Code

1. Open terminal in the project directory
2. Run: `claude`
3. Give this comprehensive prompt:

```
Please create an ERB form mapping for tax_form_2024.

CRITICAL REQUIREMENTS:
1. Check FieldNameAlt descriptions in output/extracted_keys/tax_form_2024_keys.txt
   - DO NOT trust field names like VeteransLastName[0]
2. Review the actual PDF at input/pdfs/tax_form_2024.pdf to understand form structure
3. Map fields from input/payloads/tax_form_2024.json
4. Reference examples in Example_form_mappings/ for ERB syntax
5. Enforce character limits found in FieldMaxLength
6. Use YES/NO/Off for radio buttons, not 1/0
7. Handle conditional fields properly
8. Save to output/form_mappings/tax_form_2024.erb

Remember: FieldNameAlt tells you the REAL purpose of each field!
```

#### Option B: Using Cursor

1. Open the project in Cursor
2. Open these files in tabs:
   - `output/extracted_keys/tax_form_2024_keys.txt` (CRITICAL!)
   - `input/payloads/tax_form_2024.json`
   - `input/pdfs/tax_form_2024.pdf` (in external viewer)
   - An example from `Example_form_mappings/`
3. Create: `output/form_mappings/tax_form_2024.erb`
4. Use Cursor's AI with the requirements above

### Step 7: MANDATORY Quality Assurance Process

**Never skip QA! Field name confusion is the #1 source of errors.**

#### 7.1 Field Purpose Verification

For EVERY field in your ERB:

```bash
# Check what each field REALLY is
grep -A3 "form1\[0\]\.Page2\[0\]\.VeteransLastName\[0\]" output/extracted_keys/tax_form_2024_keys.txt
```

Verify:
- FieldNameAlt matches your JSON mapping
- You're not mapping veteran data to spouse fields
- Email fields aren't being used for names

#### 7.2 Character Limit Validation

```bash
# Find all character limits
grep "FieldMaxLength" output/extracted_keys/tax_form_2024_keys.txt

# Verify your ERB enforces them
grep "\.\.\[0\.\." output/form_mappings/tax_form_2024.erb
```

#### 7.3 Radio Button Verification

```bash
# Find all radio buttons and their valid values
grep -A4 "FieldType: Button" output/extracted_keys/tax_form_2024_keys.txt

# Check your mappings use correct values
grep "RadioButtonList" output/form_mappings/tax_form_2024.erb
```

Should see: `'YES'`, `'NO'`, `'Off'` (not 1/0)

#### 7.4 Conditional Logic Check

Review sections that should only populate under certain conditions:

```erb
# Good - conditional population
<% if form.data['hasSpouse'] %>
  "SpouseSSN[0]": "<%= form.data.dig('spouse', 'ssn') %>",
<% else %>
  "SpouseSSN[0]": "",
<% end %>

# Bad - always populates
"SpouseSSN[0]": "<%= form.data.dig('spouse', 'ssn') %>",
```

#### 7.5 Cross-Reference with PDF

Open the PDF and ERB side-by-side:
1. For each PDF section, find corresponding ERB section
2. Verify field order matches
3. Check that conditional instructions are followed

### Step 8: Test with Different Scenarios

Create test payloads for edge cases:

```bash
# Test with minimal data
cp input/payloads/tax_form_2024.json input/payloads/test_minimal.json
# Edit to remove optional fields

# Test with all fields populated
cp input/payloads/tax_form_2024.json input/payloads/test_complete.json
# Edit to include all possible fields

# Test with different conditional branches
cp input/payloads/tax_form_2024.json input/payloads/test_unmarried.json
# Edit hasSpouse: false
```

### Step 9: Final Verification Checklist

Run through this checklist for EVERY form:

- [ ] **PDF Reviewed**: Visually examined the actual PDF form
- [ ] **FieldNameAlt Verified**: Every field's true purpose confirmed
- [ ] **Character Limits**: All MaxLength constraints enforced
- [ ] **Radio Buttons**: Using YES/NO/Off values from FieldStateOption
- [ ] **Conditionals**: Proper if/else blocks for optional sections
- [ ] **Empty Defaults**: Conditional fields have "" when not applicable
- [ ] **Date Handling**: Using form.signature_date&.strftime() where appropriate
- [ ] **Safe Navigation**: Using &. and dig() for nil safety
- [ ] **Comments**: Every field has comment showing FieldNameAlt
- [ ] **ERB Syntax**: Valid and properly formatted

## Common Issues and Solutions

### Issue: "Veteran fields mapping to wrong person"

**Symptom**: Veteran data appearing in spouse fields or vice versa

**Solution**:
```bash
# Check the actual purpose
grep "VeteransLastName" output/extracted_keys/form_keys.txt
# Look at FieldNameAlt - it might say "SPOUSE NAME"!
```

### Issue: "Radio buttons showing as numbers"

**Symptom**: PDF shows 1/0 instead of checked boxes

**Solution**:
```bash
# Find valid options
grep -A3 "RadioButtonList\[0\]" output/extracted_keys/form_keys.txt
# Look for FieldStateOption: YES, NO, Off
```

Use exactly those values:
```erb
"RadioButtonList[0]": "<%= form.data['married'] ? 'YES' : 'NO' %>",
```

### Issue: "Text cut off in PDF fields"

**Symptom**: Data truncated in generated PDF

**Solution**:
```bash
# Find the limit
grep "YourFieldName" -A5 output/extracted_keys/form_keys.txt
# Look for FieldMaxLength: 18
```

Enforce in ERB:
```erb
"FieldName[0]": "<%= form.data['name']&.[](0..17) %>", <%# Max 18 chars %>
```

### Issue: "Fields populated when they shouldn't be"

**Symptom**: Conditional fields always have data

**Solution**: Add proper conditional blocks:
```erb
<% if form.data['hasCondition'] %>
  "ConditionalField[0]": "<%= form.data['conditionalData'] %>",
<% else %>
  "ConditionalField[0]": "",
<% end %>
```

## Batch Processing Multiple Forms

To process multiple forms efficiently:

```bash
# 1. Place all PDFs and JSONs
ls input/pdfs/
# form1.pdf  form2.pdf  form3.pdf

ls input/payloads/
# form1.json  form2.json  form3.json

# 2. Extract all keys at once
./scripts/extract_pdf_keys.sh --all

# 3. Process each with proper QA
for form in form1 form2 form3; do
  echo "Processing $form..."

  # View the PDF
  echo "Step 1: Review PDF at input/pdfs/${form}.pdf"

  # Check FieldNameAlt
  echo "Step 2: Checking field descriptions..."
  grep "FieldNameAlt" output/extracted_keys/${form}_keys.txt | head -20

  # Generate mapping with AI agent
  echo "Step 3: Generate ERB mapping..."
  # Use Claude or Cursor with comprehensive prompt

  # QA verification
  echo "Step 4: Running QA checks..."
  # Run all QA steps listed above
done
```

## Red Flags That Require Investigation

If you see any of these, STOP and investigate:

1. **Field name doesn't match content**:
   - `VeteransName` being used for non-veteran data
   - `DOB` fields used for non-date values

2. **Suspicious array indices**:
   - Same field name with different indices having unrelated purposes
   - `[0]` and `[1]` of same field doing completely different things

3. **Character limits being ignored**:
   - No `&.[](0..max)` substring operations
   - Long strings going into limited fields

4. **Radio buttons with wrong values**:
   - Using 1/0, true/false instead of YES/NO/Off
   - Not checking FieldStateOption values

## Getting Help

- **Always check FieldNameAlt first** - It's the source of truth
- **View the PDF** - Visual context prevents many errors
- **Review examples** - Pattern matching helps
- **Test edge cases** - Empty/full/conditional scenarios

## Key Takeaway

**Never trust field names!** Always verify with FieldNameAlt descriptions. A few extra minutes of QA prevents hours of debugging later.