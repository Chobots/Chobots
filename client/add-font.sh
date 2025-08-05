#!/bin/bash

# Script to add fonts to the Chobots project
# Usage: ./add-font.sh /path/to/your/font.ttf

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/font.ttf"
    echo "This will copy the font to the fonts directory and update the Docker build"
    exit 1
fi

FONT_PATH="$1"
FONT_NAME=$(basename "$FONT_PATH")

# Check if font file exists
if [ ! -f "$FONT_PATH" ]; then
    echo "Error: Font file '$FONT_PATH' not found"
    exit 1
fi

# Create fonts directory if it doesn't exist
mkdir -p fonts

# Copy font to fonts directory
cp "$FONT_PATH" "fonts/$FONT_NAME"

echo "Font '$FONT_NAME' has been copied to fonts/ directory"
echo "The font will be automatically included in the next Docker build"
echo ""
echo "To rebuild with the new font, run:"
echo "docker-compose build client" 