# Claude Code Instructions for Form Mapping Generation

## Your Task

You will create an ERB form mapping file that maps frontend JSON payload fields to PDF form field keys.

## Input Files Location

1. **PDF Field Keys**: `output/extracted_keys/{form_name}_keys_names_only.txt`
   - Contains the list of PDF form field names
   - Also check `{form_name}_keys.txt` for full field metadata if needed

2. **JSON Payload**: `input/payloads/{form_name}.json`
   - Contains the frontend data structure

3. **Example Mappings**: `Example_form_mappings/*.erb`
   - Reference these for proper ERB syntax and mapping patterns

## Step-by-Step Process

### 1. Analyze the Inputs

First, read and understand all three inputs:

```bash
# Read the PDF field names
cat output/extracted_keys/{form_name}_keys_names_only.txt

# Read the JSON payload structure
cat input/payloads/{form_name}.json

# Examine an example mapping
cat Example_form_mappings/*.erb
```

### 2. Identify Mapping Patterns

Look for patterns between JSON fields and PDF keys:
- Direct name matches (e.g., `first_name` → `FirstName`)
- Semantic matches (e.g., `ssn` → `SocialSecurityNumber`)
- Nested JSON paths (e.g., `address.street` → `StreetAddress`)
- Array handling (e.g., `dependents[0].name` → `Dependent1Name`)

### 3. Generate the ERB Mapping

Create the mapping file following these conventions:

```erb
<%# Form Mapping: {Form Name} %>
<%# Generated: {Date} %>

<%# Basic field mapping %>
<%= pdf_field "PDFFieldName", json_data["json_field"] %>

<%# Nested object mapping %>
<%= pdf_field "Address", json_data.dig("contact", "address", "street") %>

<%# Conditional mapping %>
<% if json_data["has_spouse"] %>
  <%= pdf_field "SpouseName", json_data["spouse_name"] %>
<% end %>

<%# Array/list handling %>
<% json_data["children"]&.each_with_index do |child, index| %>
  <%= pdf_field "Child#{index + 1}Name", child["name"] %>
  <%= pdf_field "Child#{index + 1}Age", child["age"] %>
<% end %>

<%# Computed/transformed values %>
<%= pdf_field "FullName", "#{json_data['first_name']} #{json_data['last_name']}" %>

<%# Checkbox handling %>
<%= pdf_field "IsEmployed", json_data["employed"] ? "Yes" : "No" %>
```

### 4. Common Mapping Patterns

#### Date Formatting
```erb
<%= pdf_field "DateOfBirth", format_date(json_data["dob"]) %>
```

#### Phone Number Formatting
```erb
<%= pdf_field "PhoneNumber", format_phone(json_data["phone"]) %>
```

#### Currency/Number Formatting
```erb
<%= pdf_field "AnnualIncome", number_to_currency(json_data["income"]) %>
```

#### Address Components
```erb
<%= pdf_field "FullAddress", [
  json_data.dig("address", "street"),
  json_data.dig("address", "city"),
  json_data.dig("address", "state"),
  json_data.dig("address", "zip")
].compact.join(", ") %>
```

### 5. Validation Checklist

Before saving the mapping file, ensure:

- [ ] All PDF fields have been addressed (mapped or intentionally skipped)
- [ ] All relevant JSON data is being used
- [ ] Proper nil/null handling with `&.` and `dig()`
- [ ] Arrays and nested objects are properly handled
- [ ] Date/time/currency formatting is applied where needed
- [ ] ERB syntax is valid (proper `<%` and `%>` tags)

### 6. Output Location

Save the generated mapping file to:
```
output/form_mappings/{form_name}.erb
```

## Example Command Sequence

```bash
# 1. Check what forms are available
ls input/pdfs/
ls input/payloads/

# 2. Read the extracted keys
cat output/extracted_keys/tax_form_keys_names_only.txt

# 3. Read the JSON payload
cat input/payloads/tax_form.json

# 4. Look at examples
ls Example_form_mappings/
cat Example_form_mappings/example1.erb

# 5. Create the mapping
# [Generate the ERB content based on analysis]

# 6. Save to output
# Write to output/form_mappings/tax_form.erb
```

## Special Considerations

1. **Missing Fields**: If a PDF field has no corresponding JSON data, add a comment:
   ```erb
   <%# TODO: No JSON field found for PDF field "MiddleInitial" %>
   ```

2. **Complex Transformations**: Document any complex logic:
   ```erb
   <%# Calculate total income from multiple sources %>
   <% total_income = json_data["salary"] + json_data["bonuses"] + json_data["other_income"] %>
   <%= pdf_field "TotalIncome", total_income %>
   ```

3. **Validation Notes**: Add comments for fields requiring validation:
   ```erb
   <%# NOTE: SSN format should be validated before mapping %>
   <%= pdf_field "SSN", format_ssn(json_data["social_security_number"]) %>
   ```

## Getting Help

If you encounter:
- Ambiguous mappings: Check the example files for similar patterns
- Missing data: Document it with a TODO comment
- Complex transformations: Break them down into helper methods

Remember: The goal is to create a maintainable, readable ERB file that accurately maps the frontend data to the PDF form fields.