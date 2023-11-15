## Run PDAL in a Docker Container

This is a tutorial to demonstrate how to containerize and run PDAL. [PDAL](https://pdal.io/en/2.6.0/) is a stand-alone software package that can analyze and manipulate point cloud data files such as .las and .laz. In this tutorial, we will filter a Cloud Optimized point cloud (.copc.laz) to classify the ground points from the tree canopy points. The point cloud file is located in this repository and is called `odm_georeferenced_model.copc.laz`. It currently has no point classification. 

### 1. Clone this repository to your local machine

`git clone https://github.com/jeffgillan/pdal_filters.csf.git`

### 2. Change directories into the newly cloned repository

`cd pdal_filters.csf`

### 3. Run the Container

`docker run -v $(pwd):/data jeffgillan/pdal_csf:1.0`

Your if everything worked correctly, you should have a new file `odm_georeferenced_model.copc.copc.laz` in your present working directory.

You can visualize and see the classification using https://viewer.copc.io/

___
</br>

## How to Build this Docker Container

### 1. PDAL Pipeline

Analyzing pointclouds in PDAL requires users to specify processing steps within a json file. PDAL uses the term ['pipeline'](https://pdal.io/en/2.6.0/pipeline.html) to describe this json file.

#### Create an empty json file 

`touch filter_csf.json`
</br>

#### Open the pipeline file

`nano filter_csf.json`

</br>

#### Write this info in the pipeline file. It will convert .las & .laz files to cloud optimized point clouds (.copc.laz)
```
[
    "file.las",
    {
        "type":"filters.csf"
    },
    "output.copc.laz"
]
```
</br>

### 2. Create a shell script

The shell script will loop through a directory (within the container) and find all .laz and .las files and then convert them to copc.laz. The shell script references the json file (pipeline), so the path to the json needs to be specified within the shell script. 

`touch pdal_csf.sh`

#### Edit the shell script
`nano pdal_csf.sh`

```
#!/bin/bash

# Define the pipeline JSON file
pipeline="/app/filter_csf.json"

# Loop over LAS/LAZ files in a directory and subdirectories. It this example, it loops over `/data` in the container. 
find /data -type f \( -name "*.laz" -o -name "*.copc.laz" \) -print0 | while IFS= read -r -d '' file; do
    # Get the file extension
    extension="${file##*.}"

    # Run the pipeline with the appropriate reader based on the file extension
    if [[ "$extension" == "laz" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.laz}.copc.laz"
    elif [[ "$extension" == "copc.laz" ]]; then
        pdal pipeline -i "$pipeline" --readers.las.filename="$file" --writers.copc.filename="${file%.copc.laz}.copc.laz"
    fi
done
```

### 3. Create a Dockerfile 

You are creating a Docker image that includes a PDAL base image, the json pipeline file, and the shell script. 

#### Create an empty Dockerfile

`touch Dockerfile`

#### Edit the Dockerfile

`nano Dockerfile`

```
FROM pdal/pdal:sha-597ab2df

WORKDIR /app

COPY pdal_csf.sh /app/pdal_csf.sh

COPY filter_csf.json /app/filter_csf.json

RUN chmod +x pdal_csf.sh

ENTRYPOINT ["/app/pdal_csf.sh"]
```

The following is happening in the Dockerfile:

A PDAL base image is being pulled from Dockerhub

I set the working directory of the container to `/app`

I copy in the shell script to the path `/app`

I copy in the pipeline json file to the path `/app`

I run `chmod +x` on the shell script to give everyone permissions

The entrypoint is where the container starts. I want it to start with the shell script.

### 4. Build the docker image
You are telling it to build an image with the name 'jeffgillan/pdal_csf' with the tag '1.0'. You are building from the Dockerfile in the current working directory '.'

`docker build -t jeffgillan/pdal_csf:1.0 .`

### 5. Run the container 
You are mounting a local volume (-v) directory to the container (`/data`). This local directory should have all of the point clouds files you want to convert. `$(pwd)` is telling it that the point clouds are in the current working directory. Alternatively, you could specify the point clouds are locating in any local directory.

`docker run -v $(pwd):/data jeffgillan/pdal_csf:1.0`


### 6. Outputs

The tool should output `.copc.copc.laz` files to the same directory where the input point clouds were storesd.    

### 7. Upload Image to Docker Hub

`docker push jeffgillan/pdal_csf:1.0`

</br>
____

## Running Pdal from local conda environment

Create a new conda environment

`conda create --yes --name pdal_copc --channel conda-forge pdal`


In your conda environment (conda activate pdal_copc) run the following commands to run the shell script

```
chmod +x pdal_csf.sh
./pdal_csf.sh
```


