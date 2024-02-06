#!/usr/bin/env bash

# *******************************************
# Import read groups header information from input BAM file.
# Replace SAMPLE and LIBRARY or only SAMPLE across read groups.
# Re-header the target BAM file with the modified read groups.
# Index the target file.
#
# !! This script will only re-header the target BAM file
# and has been developed to pair with methylink script
# that is already lifting RG tags over for single reads.
# *******************************************

## Usage
USAGE="Usage: ImportReadGroups_methylink.sh -i <input_file_bam> -t <target_file_bam> -s <sample_name> [-l <library>] [-o output_prefix]"

## Default args
output_prefix="output"
nt=$(nproc)

## Functions
check_args()
{
  arg_names=($@)
  for arg_name in ${arg_names[@]}; do
      [ -z ${!arg_name} ] && \
      echo "Missing Argument <${arg_name}>" 1>&2 && \
      echo $USAGE 1>&2 && \
      exit 1
  done
  return 0
}

## Bash command line definition
while getopts 'i:t:s:l:o:h' opt; do
  case $opt in
    # Required arguments
    i) input_file_bam=${OPTARG} ;;
    t) target_file_bam=${OPTARG} ;;
    s) sample_name=${OPTARG} ;;
    # Optional arguments
    l) library=${OPTARG} ;;
    o) output_prefix=${OPTARG} ;;
    ?|h)
      echo $USAGE 1>&2
      exit 1
      ;;
  esac
done
shift $(($OPTIND -1))

## Check arguments
check_args input_file_bam target_file_bam sample_name

## Collect target header
samtools view --no-PG -H $target_file_bam > TARGET_HEADER

## Carry over @PG definitions
samtools view --no-PG -H $input_file_bam | grep "^@PG" >> TARGET_HEADER

## Update @RG and append to target header
if [ ! -z ${library} ]; then
  samtools view --no-PG -H $input_file_bam | grep "^@RG" | \
    sed -e "s/SM:[^\t]*/SM:${sample_name}/" -e "s/LB:[^\t]*/LB:${sample_name}.${library}/" >> TARGET_HEADER
else
  samtools view --no-PG -H $input_file_bam | grep "^@RG" | \
    sed -e "s/SM:[^\t]*/SM:${sample_name}/" >> TARGET_HEADER
fi

# Re-header
samtools reheader --no-PG TARGET_HEADER $target_file_bam > ${output_prefix}.bam || exit 1

# Index
samtools index -@ $nt ${output_prefix}.bam || exit 1

# Check BAM integrity
py_script="
import sys, os

def check_EOF(filename):
    EOF_hex = b'\x1f\x8b\x08\x04\x00\x00\x00\x00\x00\xff\x06\x00\x42\x43\x02\x00\x1b\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    size = os.path.getsize(filename)
    fb = open(filename, 'rb')
    fb.seek(size - 28)
    EOF = fb.read(28)
    fb.close()
    if EOF != EOF_hex:
        sys.stderr.write('EOF is missing\n')
        sys.exit(1)
    else:
        sys.stderr.write('EOF is present\n')

check_EOF('${output_prefix}.bam')
"

python -c "$py_script" || exit 1
