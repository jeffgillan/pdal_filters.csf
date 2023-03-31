# pdal_copc
This repo has pdal scripts to analyze point clouds

Documentation is found [here](https://pdal.io/en/2.5.2)


json file

```
[
    "file.las",
    "output.copc.laz"
]
```

command line

```
find . -type f \( -name "*.las" -o -name "*.laz" \) -print0 | while IFS= read -r -d '' file; do     extension="${file##*.}";     if [[ "$extension" == "las" ]]; then         pdal pipeline -i copc.json --readers.las.filename="$file" --writers.copc.filename="${file%.las}.copc.laz";     elif [[ "$extension" == "laz" ]]; then         pdal pipeline -i copc.json --readers.las.filename="$file" --writers.copc.filename="${file%.laz}.copc.laz";     fi; done
```


