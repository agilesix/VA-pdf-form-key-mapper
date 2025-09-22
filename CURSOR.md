# Cursor AI Instructions for Form Mapping Generation

## Your Task

Generate an ERB form mapping file that connects frontend JSON payload fields to PDF form field keys.

## ⚠️ CRITICAL WARNING: Field Names Are Deceptive!

**The #1 mistake**: Trusting PDF field names! A field named `VeteransLastName[0]` might actually be for the spouse's name or even an email address field. **ALWAYS check FieldNameAlt descriptions!**

## Project Structure Overview

```
Key_Mapping/
├── input/
│   ├── pdfs/          → PDF forms (VIEW THESE!)
│   └── payloads/      → JSON payloads from frontend
├── output/
│   ├── extracted_keys/ → PDF field keys with FieldNameAlt descriptions
│   └── form_mappings/  → Your generated ERB files go here
└── Example_form_mappings/ → Reference examples
```

## Step-by-Step Instructions with Cursor

### Step 1: Open All Relevant Files

Use Cursor's multi-tab feature to open these simultaneously:

1. **PDF Viewer Tab**: Open `input/pdfs/{form_name}.pdf`
   - Use external PDF viewer if Cursor can't display
   - Keep this visible to understand form structure

2. **Full Keys File Tab**: `output/extracted_keys/{form_name}_keys.txt`
   - This contains the CRITICAL FieldNameAlt descriptions
   - Search for "FieldNameAlt" to see actual field purposes

3. **JSON Payload Tab**: `input/payloads/{form_name}.json`
   - Use Cursor's JSON formatter for better readability

4. **Example Tabs**: Open ALL files from `Example_form_mappings/`
   - **MANDATORY**: Review ALL three examples (vba_21_10210.json.erb, vba_21_4140.json.erb, vba_21_4142.json.erb)
   - Study how they use `form.data.dig()` vs `form.signature_date`
   - Copy their exact patterns for character limits, conditionals, and radio buttons

### Step 2: Analyze with Cursor's Search

Use Cmd/Ctrl+F in the keys file to find:
- `FieldNameAlt:` - Shows the TRUE purpose of each field
- `FieldMaxLength:` - Character limits you must enforce
- `FieldType: Button` - Radio buttons/checkboxes
- `FieldStateOption:` - Valid values (YES/NO/Off)

### Step 3: Study ALL Examples First (CRITICAL)

Before creating your mapping, open and study ALL three example files:
- `Example_form_mappings/vba_21_10210.json.erb`
- `Example_form_mappings/vba_21_4140.json.erb`
- `Example_form_mappings/vba_21_4142.json.erb`

Use Cursor's search (Cmd/Ctrl+F) in the examples to find:
- `form.data` - How they access JSON data
- `form.signature_date` - When they use this vs data hash
- `&.[](` - Character limit patterns
- `<% if` - Conditional patterns
- `? 1 : 0` or `? 'YES' : 'NO'` - Boolean/radio patterns

### Step 4: Create Your Mapping File

Create new file: `output/form_mappings/{form_name}.erb`

#### ERB Template with Best Practices (Based on ALL Examples)

```erb
{
  <%# Form: {Form Number} - {Form Title} %>
  <%# Generated: <%= Date.today %> %>
  <%# ================================================ %>
  <%# IMPORTANT: Field names are misleading! %>
  <%# Always check FieldNameAlt for actual purpose! %>
  <%# ================================================ %>

  <%# Page 1 - {Section from PDF} %>

  <%# ACTUAL PURPOSE from FieldNameAlt (not field name!) %>
  "misleadingFieldName[0]": "<%= form.data.dig('correct', 'json', 'path') %>",

  <%# Handle character limits %>
  "SomeField[0]": "<%= form.data['field']&.[](0..17) %>", <%# Max 18 chars %>

  <%# Radio buttons - use state options, not 0/1 %>
  "RadioButtonList[0]": "<%= form.data['condition'] ? 'YES' : 'NO' %>",

  <%# Conditional sections %>
  <% if form.data['hasRemarried'] %>
    <%# Only populate if condition is true %>
    "ConditionalField[0]": "<%= form.data.dig('remarriage', 'data') %>",
  <% else %>
    <%# Leave empty or use "Off" for radio buttons %>
    "ConditionalField[0]": "",
    "RadioButton[0]": "Off",
  <% end %>

  <%# Signature dates use form object directly %>
  "DateMonth[0]": "<%= form.signature_date&.strftime('%m') %>",
  "DateDay[0]": "<%= form.signature_date&.strftime('%d') %>",
  "DateYear[0]": "<%= form.signature_date&.strftime('%Y') %>"
}
```

### Step 4: Common Field Mapping Gotchas

| What You See | What It Actually Is | How to Find Out |
|--------------|-------------------|-----------------|
| `VeteransLastName[0]` | Could be spouse name | Check FieldNameAlt: "1C. NAME OF SPOUSE" |
| `VeteransLastName[1]` | Could be email field | Check FieldNameAlt: "4. E-MAIL ADDRESS" |
| `DOBmonth[1]` | Could be age field | Check FieldNameAlt: "AGE AT MARRIAGE" |
| `Daytime1[0]` | Phone area code | Check FieldNameAlt for context |

### Step 5: Use Cursor's Features for QA

#### A. Multi-cursor Editing
When you have similar fields, use Cursor's multi-cursor (Alt+Click) to edit them simultaneously:
```erb
"form1[0].Page2[0].DOBmonth[0]": "<%= form.data.dig('date', 'month') %>",
"form1[0].Page2[0].DOBday[0]": "<%= form.data.dig('date', 'day') %>",
"form1[0].Page2[0].DOByear[0]": "<%= form.data.dig('date', 'year') %>",
```

#### B. Find & Replace with Regex
Use Cursor's regex search to find patterns:
- Find: `\[(\d+)\]":`
- To locate all array indices

#### C. Split View
1. Split editor vertically
2. Left: Your ERB file
3. Right: The keys.txt file with FieldNameAlt
4. Scroll both simultaneously to verify mappings

### Step 6: Validation Checklist in Cursor

Use Cursor's checkbox feature in markdown preview:

- [ ] **PDF Reviewed**: Opened and understood form structure
- [ ] **FieldNameAlt Checked**: Every field's true purpose verified
- [ ] **Character Limits**: Added `&.[](0..max)` where needed
- [ ] **Radio Buttons**: Using YES/NO/Off, not 1/0
- [ ] **Conditionals**: Proper if/else blocks for optional sections
- [ ] **Empty Fields**: Conditional fields have "" when not applicable
- [ ] **Date Format**: Using `form.signature_date&.strftime()`
- [ ] **Safe Navigation**: Using `&.` and `dig()` for nil safety

### Step 7: Quick Validation Commands

Open Cursor's terminal and run:

```bash
# Check ERB syntax
erb -x -T - output/form_mappings/{form_name}.erb | ruby -c

# View FieldNameAlt descriptions
grep -n "FieldNameAlt" output/extracted_keys/{form_name}_keys.txt

# Check character limits
grep -n "FieldMaxLength" output/extracted_keys/{form_name}_keys.txt

# See radio button options
grep -A2 "FieldType: Button" output/extracted_keys/{form_name}_keys.txt
```

## Real Example: The Deceptive Field Names

From actual form VBA-21P-0537:

```erb
<%# ❌ WRONG - Trusting the field name %>
"form1[0].Page2[0].VeteransLastName[0]": "<%= form.data.dig('veteran', 'fullName', 'last') %>",

<%# ✅ CORRECT - Based on FieldNameAlt check %>
<%# FieldNameAlt: "1C. NAME OF SPOUSE. Enter Last Name." %>
"form1[0].Page2[0].VeteransLastName[0]": "<%= form.data.dig('remarriage', 'spouseName', 'last') %>",

<%# ❌ WRONG - Assuming it's a date field %>
"form1[0].Page2[0].DOBmonth[1]": "<%= form.data.dig('some', 'date', 'month') %>",

<%# ✅ CORRECT - It's actually age! %>
<%# FieldNameAlt: "1G. WHAT WAS YOUR AGE AT THE TIME OF YOUR MARRIAGE?" %>
"form1[0].Page2[0].DOBmonth[1]": "<%= form.data.dig('remarriage', 'ageAtMarriage') %>",
```

## Cursor Shortcuts for Efficiency

| Action | Shortcut | Use Case |
|--------|----------|----------|
| Multi-cursor | Alt+Click | Edit similar fields |
| Find in file | Cmd/Ctrl+F | Search FieldNameAlt |
| Replace | Cmd/Ctrl+H | Fix field patterns |
| Split view | Cmd/Ctrl+\ | View keys + ERB |
| Format JSON | Shift+Alt+F | Pretty print payload |
| Toggle comment | Cmd/Ctrl+/ | Add ERB comments |

## Troubleshooting in Cursor

### Issue: "Field mapping seems wrong"
1. Search for the field in keys.txt
2. Read the FieldNameAlt description
3. Check the PDF to confirm
4. Update your mapping

### Issue: "Radio button not working"
1. Check FieldStateOption values in keys.txt
2. Use exact values: YES/NO/Off
3. Not 1/0 or true/false

### Issue: "Text truncated in PDF"
1. Find FieldMaxLength in keys.txt
2. Add substring: `&.[](0..maxlength-1)`

### Issue: "Date not populating"
1. Check if it's actually a date field (might be age, etc.)
2. Use `form.signature_date` not `form.data['signatureDate']`

## Final Quality Check

Before saving, use Cursor's search to verify:

1. **Search for field names without comments** - Every field should have a comment explaining its FieldNameAlt purpose
2. **Search for `]:"` to find all mappings** - Ensure each has proper ERB syntax
3. **Search for `RadioButtonList`** - Verify YES/NO/Off values
4. **Search for `<%` and `%>`** - Ensure all ERB tags are balanced

## Pro Tip: Create a Cursor Snippet

Save this as a snippet for quick field mapping:

```erb
<%# ${1:FieldNameAlt description} %>
"${2:fieldname}": "<%= form.data.dig(${3:'path', 'to', 'field'}) %>",
```

Remember: **FieldNameAlt is truth. Field names lie!**