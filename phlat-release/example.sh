phlatdir=~/phlat-release
datadir=~/phlat-release/example
indexdir=~/phlat-release/b2folder
rsdir=~/phlat-release/results
b2url=~/bowtie2-2.0.0-beta7/bowtie2
tag="example"
fastq1=${tag}"_1.fastq.gz"
fastq2=${tag}"_2.fastq.gz"

mkdir $rsdir

python -O ${phlatdir}/dist/PHLAT.py -1 ${datadir}/${fastq1} -2 ${datadir}/${fastq2} -index $indexdir -b2url $b2url -orientation "--fr" -tag $tag -e $phlatdir -o $rsdir -tmp 0


