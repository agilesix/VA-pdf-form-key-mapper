#!/usr/bin/env ruby
# Validates ERB form mapping files use snake_case, not camelCase
#
# Usage: ruby scripts/validate_snake_case.rb output/form_mappings/form_name.erb
#
# Exit codes:
#   0 = All keys are properly snake_cased
#   1 = Found camelCase violations or error

# Colors for output
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
NC = "\033[0m" # No Color

def print_error(msg)
  puts "#{RED}#{msg}#{NC}"
end

def print_success(msg)
  puts "#{GREEN}#{msg}#{NC}"
end

def print_warning(msg)
  puts "#{YELLOW}#{msg}#{NC}"
end

# Check arguments
if ARGV.length != 1
  print_error("Usage: #{$0} <erb_file_path>")
  puts ""
  puts "Example:"
  puts "  #{$0} output/form_mappings/vba_21p_601.json.erb"
  exit 1
end

erb_file = ARGV[0]

# Check if file exists
unless File.exist?(erb_file)
  print_error("Error: File not found: #{erb_file}")
  exit 1
end

# Check if file is readable
unless File.readable?(erb_file)
  print_error("Error: File is not readable: #{erb_file}")
  exit 1
end

violations = []
line_number = 0

begin
  File.open(erb_file, 'r') do |file|
    file.each_line do |line|
      line_number += 1

      # Match form.data.dig(...) patterns
      line.scan(/form\.data\.dig\(([^)]+)\)/) do |match|
        # Extract all quoted strings from the dig call
        keys = match[0].scan(/'([^']+)'/).flatten

        keys.each do |key|
          # Check if key is camelCase
          # Pattern: lowercase letter followed by uppercase letter
          if key =~ /[a-z][A-Z]/
            # Convert camelCase to snake_case for suggestion
            suggested = key.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

            violations << {
              line: line_number,
              key: key,
              suggested: suggested,
              context: line.strip
            }
          end
        end
      end

      # Also check array access patterns like expenses[0]['expenseType']
      line.scan(/\['([^']+)'\]/) do |match|
        key = match[0]

        # Check if key is camelCase
        if key =~ /[a-z][A-Z]/
          suggested = key.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

          violations << {
            line: line_number,
            key: key,
            suggested: suggested,
            context: line.strip
          }
        end
      end
    end
  end
rescue => e
  print_error("Error reading file: #{e.message}")
  exit 1
end

# Report results
if violations.any?
  print_error("❌ Found #{violations.size} camelCase violation(s) in #{erb_file}:")
  puts ""

  violations.each do |v|
    puts "  #{RED}Line #{v[:line]}:#{NC}"
    puts "    camelCase: #{RED}'#{v[:key]}'#{NC}"
    puts "    should be: #{GREEN}'#{v[:suggested]}'#{NC}"
    puts "    Context:   #{v[:context][0..80]}#{'...' if v[:context].length > 80}"
    puts ""
  end

  puts "#{YELLOW}💡 Tip:#{NC} The vets-api backend converts JSON keys from camelCase to snake_case."
  puts "#{YELLOW}💡 Tip:#{NC} Your ERB templates must use snake_case to match the transformed data."
  puts "#{YELLOW}💡 Tip:#{NC} See Example_form_mappings/vba_21p_601.json.erb for correct patterns."
  puts ""

  exit 1
else
  print_success("✅ All keys in #{erb_file} are properly snake_cased!")
  puts ""
  puts "Total lines scanned: #{line_number}"
  exit 0
end
