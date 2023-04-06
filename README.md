# pdal_copc
This repo has pdal scripts to analyze point clouds

Documentation for PDAL is found [here](https://pdal.io/en/2.5.2)

The json files within this repo define the pipeline processing steps to be carried out in PDAL. 

For example, the json file copc.json converts a .las point cloud format to a cloud optimized point cloud (copc)
</br>
</br>
</br>
### Create an empty json file. This will be the 'pipeline' file.

`touch copc.json`
</br>

### Open the pipeline file

`nano cocp.json`

</br>

### Write this info in the pipeline file. It will convert .las files to .copc.laz files
```
[
    "file.las",
    "output.copc.laz"
]
```
</br>
### Create an empty shell script

`touch pdal_copc.sh`

</br>

### Edit the shell script
`nano pdal_cocp.sh`

```
#!/bin/bash

#Define the pipeline JSON file
pipeline="/app/copc.json" #use this path if in a container
#pipeline="./copc.json"  #use this path if you are running the shell script on your local conda environment

### Loop over LAS/LAZ files in the current directory and subdirectories
find . -type f \( -name "*.las" -o -name "*.laz" \) -print0 | while IFS= read -r -d '' file; do
    # Get the file extension
    extension="${file##*.}"

    # Run the pipeline with the appropriate reader based on the file extension
    if [[ "$extension" == "las" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.las}.copc.laz"
    elif [[ "$extension" == "laz" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.laz}.copc.laz"
    fi
done
```


The shell script within this repo (pdal_copc.sh) will loop through a directory and find all .laz and .las files and then convert them to copc. The shell script references the json file, so the path to the json needs to be specified within the shell script. The script assumes that the .laz and .las files are in your current working directory when you run the shell script. 

```
chmod +x pdal_copc.sh
./pdal_copc.sh
```

The shell script was written by chatGPT. 
