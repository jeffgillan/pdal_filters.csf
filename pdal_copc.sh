#!/bin/bash

# Define the pipeline JSON file
pipeline="/app/copc.json"
#pipeline="./copc.json"

# Loop over LAS/LAZ files in a directory and subdirectories. It this example, it loops over `/data` in the container. 
find /data -type f \( -name "*.las" -o -name "*.laz" \) -print0 | while IFS= read -r -d '' file; do
    # Get the file extension
    extension="${file##*.}"

    # Run the pipeline with the appropriate reader based on the file extension
    if [[ "$extension" == "las" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.las}.copc.laz"
    elif [[ "$extension" == "laz" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.laz}.copc.laz"
    fi
done
