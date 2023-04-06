# pdal_copc
This repo has pdal scripts to analyze point clouds

Documentation for PDAL is found [here](https://pdal.io/en/2.5.2)

The json files within this repo define the pipeline processing steps to be carried out in PDAL. 

For example, the json file copc.json converts a .las point cloud format to a cloud optimized point cloud (copc)

#Create an empty json file

`touch copc.json`
</br>

#Open the json file

`nano cocp.json`

</br>


```
[
    "file.las",
    "output.copc.laz"
]
```

The shell script within this repo (pdal_copc.sh) will loop through a directory and find all .laz and .las files and then convert them to copc. The shell script references the json file, so the path to the json needs to be specified within the shell script. The script assumes that the .laz and .las files are in your current working directory when you run the shell script. 

```
chmod +x pdal_copc.sh
./pdal_copc.sh
```

The shell script was written by chatGPT. 
