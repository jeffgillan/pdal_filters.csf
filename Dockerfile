FROM pdal/pdal:sha-597ab2df

WORKDIR /app

COPY pdal_csf.sh /app/pdal_csf.sh

COPY filter_csf.json /app/filter_csf.json

RUN chmod +x pdal_csf.sh

ENTRYPOINT ["/app/pdal_csf.sh"]
