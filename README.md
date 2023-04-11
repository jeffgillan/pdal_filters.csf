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


The shell script within this repo (pdal_copc.sh) will loop through a directory and find all .laz and .las files and then convert them to copc. The shell script references the json file, so the path to the json needs to be specified within the shell script. The script assumes that the .laz and .las files are in your current working directory when you run the shell script. The shell script was written by chatGPT 3.5. 

### In your conda environment (conda activate pdal_copc) run the following commands to run the shell script
```
chmod +x pdal_copc.sh
./pdal_copc.sh
```

## Run PDAl in a Docker Container

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

ENTRYPOINT ["./pdal_copc.sh"]
```
The following is happening in the Dockerfile:

A pdal base image is being pulled from Dockerhub

I set the working directory of the container to `/app`

I copy in the shell script to the path `/app`

I copy in the pipeline json file to the path `/app`

I run `chmod +x` on the shell script to give everyone permissions

The entrypoint is where the container starts. I want it to start with the shell script.

### Build the docker image
You are telling it to build an image with the name 'jeffgillan/pdal_copc' with the tag '0.1'. You are building from the Dockerfile in the current working directory '.'

`docker build -t jeffgillan/pdal_copc:0.1 .`

### Upload Image to Docker Hub
```
docker push jeffgillan/pdal_copc:0.1
```

### Run the container 
You are mounting a volume (-v) to the container which has the point cloud data. It is mounting the present working directory to the /app container directory. '590' is the ID number of the docker image. 

`docker run -v $(pwd):/data 590`

I have uploaded the docker image to Dockerhub , so you can run the image by pulling directly from Dockerhub

`docker run -v $(pwd):/data jeffgillan/pdal_copc:0.2`




### Create an app in the DE to run the docker image
