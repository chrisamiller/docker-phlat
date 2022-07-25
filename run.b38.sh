#!/bin/bash

SRC_DIR=$(dirname "$0")

show_help () {
    cat <<EOF
usage: sh $0 --ARGUMENT <value>

arguments:
  -h, --help      prints this block and immediately exists

  --phlat-dir     the path to where phlat is located, DEFAULT \$SRC_DIR/phlat-release
  --data-dir      the path to the fastq data, DEFAULT \$PHLAT_DIR/example
  --tag           typically the name of the sample folder, DEFAULT example
  --samtools      the path to the samtools executable, DEFAULT /usr/local/bin/samtools
  --bam           the path to where the bam file is located, \$PHLAT_DIR/resources/normal.cram 
  --index-dir     the path to b2folder, DEFAULT \$PHLAT_DIR/b2folder
  --rs-dir        the path where the results will be, DEFAULT \$DATA_DIR/results
  --b2url         the path to where bowtie2 is located, DEFAULT /usr/bin/bowtie2 
  --ref-fasta     the path to where the reference fasta file is located, \$PHLAT_DIR/resources/all_sequences.fa


EOF
}

# die and opts based on this example
# http://mywiki.wooledge.org/BashFAQ/035
# --long-opt* example here
# https://stackoverflow.com/a/7069755
function die {
    printf '%s\n' "$1" >&2 && show_help && exit 1
}

# check arguments
while test $# -gt 0; do
    case $1 in
        -h|--help)
            show_help
            exit
            ;;
         --phlat-dir*)
            if [ ! "$2" ]; then
                PHLAT_DIR=""
            else
                PHLAT_DIR=$2
                shift
            fi
            ;;
         --data-dir*)
	    if [ ! "$2" ]; then
		DARA_DIR=""
	    else
		DATA_DIR=$2
		shift
	    fi
	    ;;
         --tag*)
	    if [ ! "$2" ]; then
		TAG=""
	    else
		TAG=$2
		shift
	    fi
	    ;;
         --samtools*)
	    if [ ! "$2" ]; then
		SAMTOOLS=""
	    else
		SAMTOOLS=$2
		shift
	    fi
	    ;;
         --bam*)
            if [ ! "$2" ]; then 
                BAM=""
            else
                BAM=$2
                shift
            fi
            ;;
        --index-dir*)
	    if [ ! "$2" ]; then
		INDEX_DIR=""
	    else
		INDEX_DIR=$2
		shift
	    fi
       	    ;;
	--rs-dir*)
	    if [ ! "$2" ]; then
		RS_DIR=""
	    else
		RS_DIR=$2
		shift
	    fi
       	    ;;
	--b2url*)
	    if [ ! "$2" ]; then
		B2URL=""
	    else
		B2URL=$2
		shift
	    fi
       	    ;;
        --ref-fasta*)
	    if [ ! "$2" ]; then
		REF_FASTA=""
	    else
		REF_FASTA=$2
		shift
	    fi
       	    ;; 

        *)
            break
            ;;
    esac
    shift
done

# double check all vars are set up
[ -z $PHLAT_DIR    ] && PHLAT_DIR="$SRC_DIR/phlat-release"
[ -z $DATA_DIR     ] && DATA_DIR="$PHLAT_DIR/example"
[ -z $TAG          ] && TAG="example"
[ -z $SAMTOOLS     ] && SAMTOOLS="/usr/local/bin/samtools"
[ -z $BAM          ] && BAM="$PHLAT_DIR/resources/normal.cram"
[ -z $INDEX_DIR    ] && INDEX_DIR="$PHLAT_DIR/b2folder"
[ -z $RS_DIR       ] && RS_DIR="$DATA_DIR/results" 
[ -z $B2URL        ] && B2URL="/usr/bin/bowtie2"
[ -z $REF_FASTA    ] && REF_FASTA="$PHLAT_DIR/resources/all_sequences.fa"


mkdir -p $RS_DIR
tmpdir=$DATA_DIR/tmp
mkdir -p $tmpdir

echo "extracting hla region from chr6, reads to alternate HLA sequences, and all unmapped reads ..."

# filter out reads directly from an existing CRAM file of alignments, only those reads that align to this region: chr6:29836259-33148325
echo "[INFO] $SAMTOOLS view -h -T $REF_FASTA $BAM chr6:29836259-33148325 >$tmpdir/reads.sam"
time $SAMTOOLS view -h -T $REF_FASTA $BAM chr6:29836259-33148325 >$tmpdir/reads.sam

# pull out only the *header* lines from the CRAM with the -H parameter. then get the sequence names and for those that match the string "HLA" do the following
echo "[INFO] $SAMTOOLS view -H -T $REF_FASTA $BAM | grep "^@SQ" | cut -f 2 | cut -f 2- -d : | grep HLA | while read chr;do"
time $SAMTOOLS view -H -T $REF_FASTA $BAM | grep "^@SQ" | cut -f 2 | cut -f 2- -d : | grep HLA | while read chr;do 

# echo "checking $chr:1-9999999"
# grab all the reads that align to each alternate "HLA" sequence

echo "[INFO] $SAMTOOLS view -T $REF_FASTA $BAM "$chr:1-9999999" >>$tmpdir/reads.sam"
time $SAMTOOLS view -T $REF_FASTA $BAM "$chr:1-9999999" >>$tmpdir/reads.sam
done

# grab all the reads that are unaligned
echo "[INFO] $SAMTOOLS view -f 4 -T $REF_FASTA $BAM >>$tmpdir/reads.sam"
time $SAMTOOLS view -f 4 -T $REF_FASTA $BAM >>$tmpdir/reads.sam

# covert from .sam to .bam format
echo "[INFO] $SAMTOOLS view -Sb -o $tmpdir/reads.bam $tmpdir/reads.sam"
time $SAMTOOLS view -Sb -o $tmpdir/reads.bam $tmpdir/reads.sam 

echo "running pircard..."
echo "[INFO]  /usr/bin/java -Xmx6g -jar /usr/picard/picard.jar SamToFastq VALIDATION_STRINGENCY=LENIENT F=$DATA_DIR/hlaPlusUnmapped_1.fastq.gz F2=$DATA_DIR/hlaPlusUnmapped_2.fastq.gz I=$tmpdir/reads.bam R=$REF_FASTA FU=$DATA_DIR/unpaired.fastq.gz"
time /usr/bin/java -Xmx6g -jar /usr/picard/picard.jar SamToFastq VALIDATION_STRINGENCY=LENIENT F=$DATA_DIR/hlaPlusUnmapped_1.fastq.gz F2=$DATA_DIR/hlaPlusUnmapped_2.fastq.gz I=$tmpdir/reads.bam R=$REF_FASTA FU=$DATA_DIR/unpaired.fastq.gz

echo "running PHLAT ..."
echo "[INFO] python2 -O ${PHLAT_DIR}/dist/PHLAT.py -1 ${DATA_DIR}/hlaPlusUnmapped_1.fastq.gz -2 ${DATA_DIR}/hlaPlusUnmapped_2.fastq.gz -index $INDEX_DIR -b2url $B2URL -orientation "--fr" -tag $TAG -e $PHLAT_DIR -o $RS_DIR -tmp 0 -p 4 >$DATA_DIR/run_phlat.sh"
time python2 -O ${PHLAT_DIR}/dist/PHLAT.py -1 ${DATA_DIR}/hlaPlusUnmapped_1.fastq.gz -2 ${DATA_DIR}/hlaPlusUnmapped_2.fastq.gz -index $INDEX_DIR -b2url $B2URL -orientation "--fr" -tag $TAG -e $PHLAT_DIR -o $RS_DIR -tmp 0 -p 4 >$DATA_DIR/run_phlat.sh
