

# Channel Access Gateway Container

##### build stage ##############################################################

# NOTE: the tags in *runtime* FROM and *developer* FROM must match
FROM ghcr.io/epics-containers/epics-base-linux-developer:work AS developer

# install additional build time dependencies
# RUN apt-get update && apt-get upgrade -y && \
#     apt-get install -y --no-install-recommends \
#     XX \
#     && rm -rf /var/lib/apt/lists/*

# get and build the required support modules
WORKDIR /repos/epics/epics-extensions
RUN git clone https://github.com/epics-modules/pcas.git && \
    git clone https://github.com/epics-extensions/ca-gateway.git
COPY config/RELEASE* .
RUN cd pcas && \
    make
RUN cd ca-gateway && \
    make

ENV DEV_PROMPT=EPICS_CAGATEWAY

##### runtime preparation stage ################################################

FROM developer AS runtime_prep

# get the products from the build stage and reduce to runtime assets only 
WORKDIR /min_files
RUN bash ${SUPPORT}/minimize.sh /repos/epics/epics-extensions

##### runtime stage #############################################################

FROM ghcr.io/epics-containers/epics-base-linux-runtime:work AS runtime

# get the products from the build stage
COPY --from=runtime_prep /min_files /
