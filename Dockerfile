FROM ubuntu:xenial

RUN apt-get update -y && apt-get install -y \
    ant \
    apt-utils \
    build-essential \
    default-jdk \
    default-jre \
    python-dev \
    python-pip \
    perl \
    zlib1g-dev

# Pysam
RUN pip2 install pysam==0.8.4 ;# PHLAT fails with later versions of pysam

# Samtools
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/bin/samtools /usr/local/bin/samtools
COPY --from=quay.io/biocontainers/samtools:1.14--hb421002_0 /usr/local/lib/libhts.so* /usr/local/lib/libtinfow.so* /usr/local/lib/libdeflate.so* /usr/local/lib/libncursesw.so* /usr/local/lib/

# Picard
ADD https://github.com/broadinstitute/picard/releases/download/2.18.1/picard.jar ./
RUN mkdir /opt/picard-2.18.1
RUN chmod -R ugo+r /opt/picard-2.18.1
RUN mv picard.jar /opt/picard-2.18.1
RUN chmod -R ugo+r /opt/picard-2.18.1/picard.jar
RUN ln -s /opt/picard-2.18.1 /opt/picard
RUN ln -s /opt/picard-2.18.1 /usr/picard 

# PHLAT
WORKDIR /opt/
COPY ./phlat-release /usr/bin/.
COPY run.b38.sh /usr/bin/.

# bowtie2
WORKDIR /usr/
ADD https://anaconda.org/bioconda/bowtie2/2.2.4/download/linux-64/bowtie2-2.2.4-py27_1.tar.bz2 /opt/
RUN tar -xvjf /opt/bowtie2-2.2.4-py27_1.tar.bz2
RUN rm -f /opt/bowtie2-2.2.4-py27_1.tar.bz2
