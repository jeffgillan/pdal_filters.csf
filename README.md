This repo describes how to run PDAl in a local conda environment and in Docker containers

PDAL is a library for reading and writing point cloud data. Documentation for PDAL is found [here](https://pdal.io/en/2.5.2)


## Running Pdal from local conda environment

`conda create --yes --name pdal_copc --channel conda-forge pdal`

</br>

### Create an empty json file. This will be the 'pipeline' file.

`touch copc.json`
</br>

### Open the pipeline file

`nano cocp.json`

</br>

### Write this info in the pipeline file. It will convert .las & .laz files to cloud optimized point clouds (.copc.laz)
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
`nano pdal_copc.sh`

```
#!/bin/bash

#Define the pipeline JSON file
pipeline="/app/copc.json" #use this path if in a container
#pipeline="./copc.json"  #use this path if you are running the shell script on your local conda environment

### Loop over LAS/LAZ files in a directory. If you are running this shell script in a container, then the script is looking for data in the `/data` in the container directory structure. 
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
```


The shell script within this repo (pdal_copc.sh) will loop through a directory (currently set to `/data` within the container) and find all .laz and .las files and then convert them to copc. It The shell script references the json file, so the path to the json needs to be specified within the shell script. The script assumes that the .laz and .las files are in your current working directory when you run the shell script. The shell script was written by chatGPT 3.5. 

### In your conda environment (conda activate pdal_copc) run the following commands to run the shell script
```
chmod +x pdal_copc.sh
./pdal_copc.sh
```

## Run PDAL in a Docker Container

Create a Dockerfile for your container that includes PDAL and any other dependencies needed for you shell script. 

`touch Dockerfile`

### Edit the Dockerfile

`nano Dockerfile`

```
FROM pdal/pdal:latest

WORKDIR /app

COPY pdal_copc.sh /app/pdal_copc.sh

COPY copc.json /app/copc.json

RUN chmod +x pdal_copc.sh

ENTRYPOINT ["/app/pdal_copc.sh"]
```
The following is happening in the Dockerfile:

A pdal base image is being pulled from Dockerhub

I set the working directory of the container to `/app`

I copy in the shell script to the path `/app`

I copy in the pipeline json file to the path `/app`

I run `chmod +x` on the shell script to give everyone permissions

The entrypoint is where the container starts. I want it to start with the shell script.

### Build the docker image
You are telling it to build an image with the name 'jeffgillan/pdal_copc' with the tag '1.0'. You are building from the Dockerfile in the current working directory '.'

`docker build -t jeffgillan/pdal_copc:1.0 .`

### Upload Image to Docker Hub
```
docker push jeffgillan/pdal_copc:1.0
```

### Run the container 
You are mounting a local volume (-v) to the container which has the point cloud data. It is mounting the present working directory to the `/data` container directory. 

`docker run -v $(pwd):/data jeffgillan/pdal_copc:1.0`

