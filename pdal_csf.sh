#!/bin/bash

# Define the pipeline JSON file
pipeline="/app/filter_csf.json"

# Loop over LAS/LAZ files in a directory and subdirectories. It this example, it loops over `/data` in the container. 
find /data -type f \( -name "*.copc.laz" \) -print0 | while IFS= read -r -d '' file; do
    # Get the file extension
    extension="${file##*.}"

    # Run the pipeline with the appropriate reader based on the file extension

    pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.copc.laz}_filtered.copc.laz"
done    
