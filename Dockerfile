#FROM machalen/bowtie2
FROM ubuntu:jammy
#FROM biocontainers/bowtie:v1.2.2dfsg-4-deb_cv1

USER root
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python-pip \
    build-essential \
    python-all-dev \
    python-setuptools \
#    python-wheel \
    zlib1g-dev

# Get pip and pysam
RUN pip2 install pysam==0.8.4 ;# PHLAT fails with later versions of pysam
RUN pip2 install gdown;

# grab the samtools instead of compiling
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/bin/samtools /usr/local/bin/samtools
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/lib/libhts.so* /usr/local/lib/libtinfow.so* /usr/local/lib/

# grab bowtie2
ADD https://anaconda.org/bioconda/bowtie2/2.2.4/download/linux-64/bowtie2-2.2.4-py27_1.tar.bz2 /tmp/
RUN tar -xvjf /tmp/bowtie2-2.2.4-py27_1.tar.bz2
RUN rm -f /tmp/bowtie2-2.2.4-py27_1.tar.bz2
#COPY --from=quay.io/biocontainers/bowtie2:latest /

# Install PHLAT
WORKDIR /opt/
COPY ./phlat-release/ ./


#RUN gunzip phlat-release-1.1_Ubuntu.tar.gz && tar -xvf phlat-release-1.1_Ubuntu.tar && \
#    rm -f phlat-release-1.1_Ubuntu.tar


# RUN gdown -O phlat-release-1.1_Ubuntu.tar.gz --id 0ByHcYNU3A9ADVnNMR2FYd1M0bGs && \
#    gunzip phlat-release-1.1_Ubuntu.tar.gz && tar -xvf phlat-release-1.1_Ubuntu.tar && \
#    rm -f phlat-release-1.1_Ubuntu.tar

# this branch assumes you've done this and cached it somewhere, so that the 3.5Gb d/l can be avoided
# #pull down the bowtie index for the hla types
# RUN gdown -O b2folder.tar.gz --id 0ByHcYNU3A9ADaHI3aVd3WXVZeWM && \
#     gunzip b2folder.tar.gz && tar -xvf b2folder.tar && mv b2folder phlat-release/ && rm -f b2folder.tar
