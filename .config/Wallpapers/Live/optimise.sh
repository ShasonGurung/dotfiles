#!/bin/bash

# Input and output directories
INPUT_DIR="$HOME/.config/Wallpapers/Live"
OUTPUT_DIR="$INPUT_DIR/optimised"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through all mp4 files in input directory
for input_file in "$INPUT_DIR"/*.mp4; do
    # Get the filename without path
    filename=$(basename "$input_file")
    # Construct output file path
    output_file="$OUTPUT_DIR/${filename%.mp4}.mp4"

    echo "Processing $filename..."
    ffmpeg -y -i "$input_file" \
 	-vf "scale=5120:1440:force_original_aspect_ratio=increase,crop=5120:1440,fps=15" \
        -c:v libx264 -crf 23 -preset veryfast -pix_fmt yuv420p \
        "$output_file"
done

echo "All videos optimised!"
