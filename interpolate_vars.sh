#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_env_file> <output_env_file>" >&2
    exit 1
fi

input_file="$1"
output_file="$2"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file does not exist." >&2
    exit 1
fi

declare -A vars
declare -a processed_lines
line_number=0

# Read and process the input file
while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_number++))
    # Preserve comments and empty lines
    if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
        processed_lines+=("$line")
        echo "$line"
        continue
    fi

    # Extract key and value
    if ! [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*) ]]; then
        echo "Invalid line format: $line" >&2
        continue
    fi

    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    # Function to resolve variable references and evaluate expressions
    function resolve_and_evaluate {
        local var_value="$1"
        # Replace variables ${VAR} or $VAR, respecting quotes
        while [[ "$var_value" =~ (\$\{?([a-zA-Z_][a-zA-Z0-9_]*)\}?) ]]; do
            local full_match="${BASH_REMATCH[1]}"
            local var_name="${BASH_REMATCH[2]}"
            local replacement="${vars[$var_name]:-${!var_name}}"
            if [ -z "$replacement" ]; then
                echo "Error: Unresolved variable \${$var_name} on line $line_number." >&2
                exit 1  # Exit the script with an error status
            fi
            # Remove enclosing quotes from the replacement if necessary
            replacement="${replacement%\'*}"
            replacement="${replacement#\'*}"
            replacement="${replacement%\"*}"
            replacement="${replacement#\"*}"
            # Replace the first occurrence
            var_value="${var_value//"$full_match"/"$replacement"}"
        done

        # Evaluate Bash expressions $(...)
        while [[ "$var_value" =~ \$(\(.*\)) ]]; do
            local expr="${BASH_REMATCH[1]}"
            local result=$(eval "$expr")  # Evaluate the command
            if [ $? -ne 0 ]; then
                echo "Error evaluating expression '$expr' on line $line_number." >&2
                exit 1
            fi
            # Replace the evaluated expression
            var_value="${var_value//"$BASH_REMATCH"/"$result"}"
        done

        echo "$var_value"
    }

    resolved_value=$(resolve_and_evaluate "$value")
    if [ $? -ne 0 ]; then
        exit 1  # Ensure that the script exits if resolve_and_evaluate encounters an error
    fi
    vars["$key"]="$resolved_value"
    processed_lines+=("$key=$resolved_value")
    echo "$key=$resolved_value"  # Echo for output to terminal
done < "$input_file"

# Write the processed lines to the output file
printf "%s\n" "${processed_lines[@]}" > "$output_file"
