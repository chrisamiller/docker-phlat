FROM ubuntu:jammy

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python-pip \
    build-essential \
    python-all-dev \
    python-setuptools \
    default-jre \
    zlib1g-dev

# Get pip and pysam
RUN pip2 install pysam==0.8.4 ;# PHLAT fails with later versions of pysam

# grab the samtools instead of compiling
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/bin/samtools /usr/local/bin/samtools
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/lib/libhts.so* /usr/local/lib/libtinfow.so* /usr/local/lib/libdeflate.so* /usr/local/lib/

# grab bowtie2
WORKDIR /usr/
ADD https://anaconda.org/bioconda/bowtie2/2.2.4/download/linux-64/bowtie2-2.2.4-py27_1.tar.bz2 /opt/
RUN tar -xvjf /opt/bowtie2-2.2.4-py27_1.tar.bz2
RUN rm -f /opt/bowtie2-2.2.4-py27_1.tar.bz2

# Get Picared  
ADD https://github.com/broadinstitute/picard/releases/download/2.18.1/picard.jar ./
RUN mkdir /opt/picard-2.18.1
RUN mv picard.jar /opt/picard-2.18.1
RUN ln -s /opt/picard-2.18.1 /opt/picard
RUN ln -s /opt/picard-2.18.1 /usr/picard 

# Install PHLAT
WORKDIR /opt/
COPY ./phlat-release/ ./
