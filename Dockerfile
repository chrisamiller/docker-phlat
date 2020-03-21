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

# this branch assumes you've done this and cached it somewhere, so that the 3.5Gb d/l can be avoided
# #pull down the bowtie index for the hla types
# RUN gdown -O b2folder.tar.gz --id 0ByHcYNU3A9ADaHI3aVd3WXVZeWM && \
#     gunzip b2folder.tar.gz && tar -xvf b2folder.tar && mv b2folder phlat-release/ && rm -f b2folder.tar
