# Cursor AI Instructions for Form Mapping Generation

## Your Task

Generate an ERB form mapping file that connects frontend JSON payload fields to PDF form field keys.

## Project Structure Overview

```
Key_Mapping/
├── input/
│   ├── pdfs/          → PDF forms (already processed)
│   └── payloads/      → JSON payloads from frontend
├── output/
│   ├── extracted_keys/ → PDF field keys (from pdftk)
│   └── form_mappings/  → Your generated ERB files go here
└── Example_form_mappings/ → Reference examples
```

## Step-by-Step Instructions

### Step 1: Identify the Form to Process

Look for matching files:
- PDF keys: `output/extracted_keys/{name}_keys_names_only.txt`
- JSON payload: `input/payloads/{name}.json`

### Step 2: Analyze the Data

1. **Open the PDF field names file**:
   - Navigate to `output/extracted_keys/`
   - Open `{form_name}_keys_names_only.txt`
   - This contains all PDF form field names

2. **Open the JSON payload**:
   - Navigate to `input/payloads/`
   - Open `{form_name}.json`
   - Understand the data structure

3. **Study the examples**:
   - Open files in `Example_form_mappings/`
   - Note the ERB syntax patterns

### Step 3: Create the Mapping

Create a new file: `output/form_mappings/{form_name}.erb`

#### Basic ERB Template Structure

```erb
<%# Form: {Form Name} %>
<%# Description: Maps {form name} JSON payload to PDF fields %>
<%# Generated: <%= Date.today %> %>

<%# ============================================ %>
<%# Personal Information Section %>
<%# ============================================ %>

<%= pdf_field "FirstName", json_data["first_name"] %>
<%= pdf_field "LastName", json_data["last_name"] %>
<%= pdf_field "Email", json_data["email"] %>

<%# ============================================ %>
<%# Address Information %>
<%# ============================================ %>

<% if json_data["address"].present? %>
  <%= pdf_field "Street", json_data["address"]["street"] %>
  <%= pdf_field "City", json_data["address"]["city"] %>
  <%= pdf_field "State", json_data["address"]["state"] %>
  <%= pdf_field "ZipCode", json_data["address"]["zip"] %>
<% end %>

<%# ============================================ %>
<%# Dynamic Lists (e.g., dependents, items) %>
<%# ============================================ %>

<% (json_data["dependents"] || []).each_with_index do |dep, i| %>
  <%= pdf_field "Dependent#{i+1}Name", dep["name"] %>
  <%= pdf_field "Dependent#{i+1}DOB", dep["date_of_birth"] %>
<% end %>
```

### Step 4: Mapping Strategies

#### Direct Mapping
When JSON field names closely match PDF field names:
```erb
<%= pdf_field "FieldName", json_data["field_name"] %>
```

#### Nested Object Access
For nested JSON structures:
```erb
<%= pdf_field "WorkPhone", json_data.dig("contact", "work", "phone") %>
```

#### Conditional Fields
For optional fields:
```erb
<% if json_data["is_married"] %>
  <%= pdf_field "SpouseName", json_data["spouse"]["name"] %>
<% end %>
```

#### Computed Values
For fields requiring calculation or formatting:
```erb
<%= pdf_field "FullName", "#{json_data['first']} #{json_data['last']}" %>
<%= pdf_field "Age", calculate_age(json_data["birth_date"]) %>
```

#### Checkboxes and Radio Buttons
For boolean or choice fields:
```erb
<%= pdf_field "HasInsurance", json_data["insured"] ? "Yes" : "No" %>
<%= pdf_field "MaritalStatus", json_data["marital_status"].capitalize %>
```

### Step 5: Handle Edge Cases

1. **Missing JSON fields**: Add TODO comments
   ```erb
   <%# TODO: No JSON mapping found for PDF field "MiddleName" %>
   <%= pdf_field "MiddleName", "" %>
   ```

2. **Array bounds**: Check array size
   ```erb
   <% (0..2).each do |i| %>
     <% if json_data["references"] && json_data["references"][i] %>
       <%= pdf_field "Reference#{i+1}", json_data["references"][i]["name"] %>
     <% end %>
   <% end %>
   ```

3. **Format conversions**: Document transformations
   ```erb
   <%# Format: (123) 456-7890 %>
   <%= pdf_field "Phone", format_phone(json_data["phone_number"]) %>

   <%# Format: MM/DD/YYYY %>
   <%= pdf_field "Date", format_date(json_data["date"], "%m/%d/%Y") %>
   ```

### Step 6: Validate Your Mapping

Checklist:
- [ ] All PDF fields are mapped or marked as TODO
- [ ] All relevant JSON data is utilized
- [ ] Proper nil checking (using `&.`, `dig`, `present?`)
- [ ] Arrays handled with bounds checking
- [ ] ERB syntax is valid
- [ ] Comments explain complex mappings

### Step 7: Save and Document

1. Save file as: `output/form_mappings/{form_name}.erb`
2. Add a header comment with:
   - Form name
   - Date created
   - Any special notes or TODOs

## Common Patterns Reference

### Date Formatting
```erb
<%# From ISO to MM/DD/YYYY %>
<%= pdf_field "BirthDate", Date.parse(json_data["dob"]).strftime("%m/%d/%Y") rescue "" %>
```

### Currency Formatting
```erb
<%= pdf_field "Salary", "$#{'%.2f' % json_data['salary']}" %>
```

### Phone Formatting
```erb
<%= pdf_field "Phone", json_data["phone"].gsub(/(\d{3})(\d{3})(\d{4})/, '(\1) \2-\3') %>
```

### Address Concatenation
```erb
<%= pdf_field "FullAddress", [
  json_data["address"]["line1"],
  json_data["address"]["line2"],
  "#{json_data["address"]["city"]}, #{json_data["address"]["state"]} #{json_data["address"]["zip"]}"
].compact.join("\n") %>
```

## Tips for Cursor Users

1. **Use Multi-cursor**: Edit similar field mappings simultaneously
2. **Use Find & Replace**: For systematic renaming patterns
3. **Split View**: Keep JSON and ERB files open side-by-side
4. **Command Palette**: Use "Format Document" to clean up ERB
5. **Extensions**: Consider ERB/Ruby extensions for syntax highlighting

## Troubleshooting

| Issue | Solution |
|-------|----------|
| PDF field not in JSON | Add TODO comment and empty string |
| JSON field not in PDF | Document in header comment |
| Complex nested data | Use `dig()` method for safe access |
| Array index mismatch | Use `.each_with_index` and bounds checking |
| Date format issues | Use `rescue ""` for parse errors |

## Final Output

Your completed ERB file should:
1. Map all PDF fields to appropriate JSON data
2. Handle missing/nil values gracefully
3. Include helpful comments
4. Follow ERB best practices
5. Be saved in `output/form_mappings/`

Remember: The goal is a clean, maintainable ERB template that accurately transforms the JSON payload into PDF form field values.