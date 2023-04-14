FROM pdal/pdal:latest


WORKDIR /app

COPY pdal_copc.sh /app/pdal_copc.sh

COPY copc.json /app/copc.json

RUN chmod +x pdal_copc.sh

ENTRYPOINT ["/app/pdal_copc.sh"]
