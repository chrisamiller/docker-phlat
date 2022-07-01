FROM ubuntu:jammy

USER root
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python-pip \
    build-essential \
    python-all-dev \
    python-setuptools \
    zlib1g-dev

# Get pip and pysam
RUN pip2 install pysam==0.8.4 ;# PHLAT fails with later versions of pysam

# grab the samtools instead of compiling
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/bin/samtools /usr/local/bin/samtools
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/lib/libhts.so* /usr/local/lib/libtinfow.so* /usr/local/lib/libdeflate.so* /usr/local/lib/

# grab bowtie2
ADD https://anaconda.org/bioconda/bowtie2/2.2.4/download/linux-64/bowtie2-2.2.4-py27_1.tar.bz2 /opt/
RUN tar -xvjf /opt/bowtie2-2.2.4-py27_1.tar.bz2
RUN rm -f /opt/bowtie2-2.2.4-py27_1.tar.bz2

# Install PHLAT
WORKDIR /opt/
COPY ./phlat-release/ ./
