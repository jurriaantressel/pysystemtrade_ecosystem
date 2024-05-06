#!/bin/bash

## Check if arguments are provided via command line or stdin
if [ $# -eq 2 ]; then
    FILE_PATH="$1"
    CONTENT="$2"
else
    echo "Usage: $0 FILE_PATH CONTENT"
    #echo "FILE_PATH=$1"
    #echo "CONTENT=$2"
    exit 1
fi

#echo "FILE_PATH=$FILE_PATH"
#echo "CONTENT=$CONTENT"


# Check if the file already exists
if [ -f "$FILE_PATH" ]; then
    # Append the content to the file
    echo -e "\n$CONTENT" >> "$FILE_PATH"
else
    # Create the file with the shebang and provided content
    echo -e "#!/bin/bash\n$CONTENT" > "$FILE_PATH"
fi

# Make the file executable
chmod +x "$FILE_PATH"

#echo "File updated/created at $FILE_PATH with content:"
#cat "$FILE_PATH"
