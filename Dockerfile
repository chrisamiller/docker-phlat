# ProTECT Dockerfile for PHLAT
#
# 
# Build with: sudo docker build --force-rm=true --no-cache -t aarjunrao/phlat:1.0 - < Dockerfile
# Run with sudo docker run -v <IO_folder>:/data aarjunrao/phlat <parameters>

# Use bowtie
#FROM aarjunrao/bowtie2:2.2.3
#FROM biocontainers/bowtie2:2.2.9
#FROM quay.io/biocontainers/bowtie2:2.4.1--py38he513fc3_0
#FROM genomicpariscentre/bowtie2:2.2.4
FROM machalen/bowtie2

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python-pip build-essential python-all-dev python-setuptools python-wheel zlib1g-dev

# Get pip and pysam
RUN pip install pysam==0.8.4 ;# PHLAT fails with later versions of pysam
RUN pip install gdown;

# Install PHLAT
WORKDIR /opt/
RUN gdown -O phlat-release-1.1_Ubuntu.tar.gz --id 0ByHcYNU3A9ADVnNMR2FYd1M0bGs && \
    gunzip phlat-release-1.1_Ubuntu.tar.gz && tar -xvf phlat-release-1.1_Ubuntu.tar && \
    rm -f phlat-release-1.1_Ubuntu.tar

RUN gdown -O b2folder.tar.gz --id 0ByHcYNU3A9ADaHI3aVd3WXVZeWM && \
    gunzip b2folder.tar.gz && tar -xvf b2folder.tar && mv b2folder phlat-release/ && rm -f b2folder.tar.gz




# #download the (large) b2folder with the HLA fastqs
# RUN curl -L "https://docs.google.com/uc?export=download&id=0ByHcYNU3A9ADaHI3aVd3WXVZeWM" > b2folder.tar.gz && \ 
#     tar -zxvf b2folder.tar.gz && mv b2folder phlat-release/

#expects the user to have the b2folder downloaded on their own

# # get wrapper_scripts
# RUN  git clone https://github.com/arkal/toil_docker_wrappers.git 
# WORKDIR /data 
# ENTRYPOINT ["sh", "/home/toil_docker_wrappers/phlat_wrapper.sh"]
# CMD ["-h"]
 
