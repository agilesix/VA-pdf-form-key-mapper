# Claude Code Instructions for Form Mapping Generation

## Your Task

You will create an ERB form mapping file that maps frontend JSON payload fields to PDF form field keys.

## ⚠️ CRITICAL: Understanding PDF Field Names

**WARNING**: PDF field names are often misleading! The actual field names (like `VeteransLastName[0]`) frequently DO NOT match their actual purpose.

### Always Check FieldNameAlt

The `FieldNameAlt` values in the extracted keys file reveal the TRUE purpose of each field. For example:
- `VeteransLastName[0]` might actually be for "1C. NAME OF SPOUSE"
- `VeteransLastName[1]` might actually be for "4. E-MAIL ADDRESS"
- `DOBmonth[1]` might actually be for "AGE AT MARRIAGE" (not a date!)

**ALWAYS examine the full keys file with FieldNameAlt descriptions:**
```bash
cat output/extracted_keys/{form_name}_keys.txt | grep -A1 -B1 "FieldNameAlt"
```

## Input Files Location

1. **PDF Field Keys with Descriptions**: `output/extracted_keys/{form_name}_keys.txt`
   - Contains CRITICAL FieldNameAlt descriptions
   - Also see `{form_name}_keys_names_only.txt` for quick reference

2. **JSON Payload**: `input/payloads/{form_name}.json`
   - Contains the frontend data structure

3. **PDF Form (Visual Reference)**: `input/pdfs/{form_name}.pdf`
   - IMPORTANT: View this to understand the form's actual layout

4. **Example Mappings**: `Example_form_mappings/*.erb`
   - **CRITICAL**: Review ALL example files (vba_21_10210.json.erb, vba_21_4140.json.erb, vba_21_4142.json.erb)
   - Study how they handle form.data vs form.signature_date
   - Learn conditional patterns and safe navigation
   - Copy their exact ERB syntax patterns

## Step-by-Step Process

### 1. Analyze the PDF Form Visually

**CRITICAL STEP** - Always view the actual PDF first:

```bash
# Open the PDF to understand the form structure
open input/pdfs/{form_name}.pdf
# Or use any PDF viewer to see the actual form
```

Understanding the form's purpose and layout helps you:
- Identify which JSON fields map to which sections
- Understand conditional logic (e.g., "If Yes, complete section 2")
- Spot field relationships and dependencies

### 2. Examine the Extracted Keys with FieldNameAlt

```bash
# Read the FULL extraction with field descriptions
cat output/extracted_keys/{form_name}_keys.txt

# Look specifically at FieldNameAlt values
grep "FieldNameAlt" output/extracted_keys/{form_name}_keys.txt

# Check field types (Text, Button/RadioButton, etc.)
grep "FieldType" output/extracted_keys/{form_name}_keys.txt
```

Pay attention to:
- **FieldNameAlt**: The TRUE purpose of the field
- **FieldMaxLength**: Character limits for text fields
- **FieldStateOption**: Valid values for radio buttons (YES/NO/Off)
- **FieldType**: Button fields are usually radio buttons/checkboxes

### 3. Understand the JSON Payload Structure

```bash
# Pretty print the JSON for better readability
cat input/payloads/{form_name}.json | python -m json.tool

# Or examine with jq if available
jq . input/payloads/{form_name}.json
```

### 4. Study ALL Example Patterns (MANDATORY)

**You MUST review ALL three example files** to understand the correct patterns:

```bash
# List all example files - review EACH one
ls -la Example_form_mappings/
# vba_21_10210.json.erb
# vba_21_4140.json.erb
# vba_21_4142.json.erb

# Study each example thoroughly
cat Example_form_mappings/vba_21_10210.json.erb
cat Example_form_mappings/vba_21_4140.json.erb
cat Example_form_mappings/vba_21_4142.json.erb

# Look for common patterns across ALL examples
grep -n "form.data" Example_form_mappings/*.erb
grep -n "form.signature_date" Example_form_mappings/*.erb
grep -n "RadioButtonList" Example_form_mappings/*.erb
grep -n "&\.\[\]" Example_form_mappings/*.erb  # Character limit patterns
grep -n "present?" Example_form_mappings/*.erb  # Conditional checks
```

Key patterns to extract from the examples:
- How they use `form.data.dig()` for nested data
- When they use `form.signature_date` vs `form.data['signatureDate']`
- How they handle character limits with `&.[](0..n)`
- Conditional field population patterns
- Radio button value formatting

### 5. Generate the ERB Mapping

Create the mapping file following these best practices:

```erb
{
  <%# Form: {Form Number} - {Form Title} %>
  <%# Generated: {Date} %>
  <%# IMPORTANT: Field names may not match their purpose - check FieldNameAlt! %>

  <%# ============================================ %>
  <%# Section Name (from PDF form) %>
  <%# ============================================ %>

  <%# Actual field purpose from FieldNameAlt %>
  "fieldname[0]": "<%= form.data.dig('json', 'path') %>",

  <%# Conditional fields - only populate when conditions are met %>
  <% if form.data['some_condition'] %>
    "fieldname[1]": "<%= form.data.dig('nested', 'value') %>",
  <% else %>
    "fieldname[1]": "",
  <% end %>

  <%# Radio buttons - use actual state options %>
  "RadioButtonList[0]": "<%= condition ? 'YES' : 'NO' %>",

  <%# Character-limited fields %>
  "EmailField[0]": "<%= form.data['email']&.[](0..29) %>",

  <%# Date fields - check if form.signature_date is available %>
  "DateMonth[0]": "<%= form.signature_date&.strftime('%m') %>",
}
```

### 6. Common Pitfalls to Avoid

1. **Trusting Field Names**: NEVER assume `VeteransLastName` is for veteran's last name
2. **Missing Character Limits**: Always check and respect FieldMaxLength
3. **Wrong Radio Button Values**: Use YES/NO/Off, not 1/0
4. **Date Format Confusion**: Some "date" fields might be single values (like age)
5. **Ignoring Conditionals**: Check if fields should only populate under certain conditions

### 7. Quality Assurance Checklist

Before finalizing your mapping:

#### A. Field Name Verification
- [ ] Checked ALL FieldNameAlt descriptions
- [ ] Verified field purposes match JSON data being mapped
- [ ] Confirmed field indices are correct (e.g., [0] vs [1])

#### B. Data Validation
- [ ] Character limits enforced with `&.[](0..max)`
- [ ] Radio buttons use correct state options (YES/NO/Off)
- [ ] Conditional logic matches form requirements
- [ ] Empty strings for unpopulated conditional fields

#### C. Cross-Reference Check
- [ ] Compared with actual PDF form visually
- [ ] Verified all JSON fields are utilized appropriately
- [ ] Checked that all required PDF fields are mapped

#### D. ERB Syntax
- [ ] Valid ERB tags (`<%` and `%>`)
- [ ] Proper use of `dig()` for nested data
- [ ] Safe navigation with `&.` for potentially nil values
- [ ] Correct use of `present?` for conditional checks

### 8. Final QA Process

Run through this comprehensive QA:

```bash
# 1. Review the complete field extraction
cat output/extracted_keys/{form_name}_keys.txt

# 2. Verify your JSON payload structure
cat input/payloads/{form_name}.json

# 3. Open and review the actual PDF
open input/pdfs/{form_name}.pdf

# 4. Check your ERB for syntax
erb -x -T - output/form_mappings/{form_name}.erb | ruby -c

# 5. Compare with similar forms
ls Example_form_mappings/
```

## Example: Field Name Mismatch

Here's a real example from form VBA-21P-0537:

```erb
<%# WRONG - Based on field name assumption %>
"form1[0].Page2[0].VeteransLastName[0]": "<%= form.data.dig('veteran', 'fullName', 'last') %>",

<%# CORRECT - Based on FieldNameAlt: "1C. NAME OF SPOUSE" %>
"form1[0].Page2[0].VeteransLastName[0]": "<%= form.data.dig('remarriage', 'spouseName', 'last') %>",
```

## Getting Help

If you encounter issues:
1. **Always check FieldNameAlt first** - The field name is probably misleading
2. **View the PDF** - Visual context clarifies field purposes
3. **Check field limits** - Respect MaxLength constraints
4. **Test with different payload scenarios** - Ensure conditionals work
5. **Reference examples** - Similar patterns likely exist

Remember: The FieldNameAlt is your source of truth, not the field name!