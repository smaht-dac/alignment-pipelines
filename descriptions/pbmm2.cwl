#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/pbmm2:VERSION

baseCommand: [pbmm2, align]

arguments: [--sort, --strip, --unmapped, --log-level, INFO]
## Extra Arguments
#   --strip - remove hifikinetics if there
#   --unmapped - keep the unmapped reads

inputs:
  # Options
  - id: nthreads_alignment
    type: int
    default: null
    inputBinding:
      position: 1
      prefix: --num-threads
    doc: Number of threads to use for alignment. |
         If not specified, the maximum number of threads will be used |
         minus one thread for BAM IO and |
         minus the number of threads specified for sorting

  - id: nthreads_sorting
    type: int
    default: null
    inputBinding:
      position: 2
      prefix: --sort-threads
    doc: Number of threads to use for sorting. |
         By default, 25% of threads specified for alignment |
         are used for sorting (maximum 8)

  - id: memory_sorting
    type: string
    default: null
    inputBinding:
      position: 3
      prefix: --sort-memory
    doc: The memory allocated per sort thread. |
         Accepting suffixes M,G

  - id: preset
    type: string
    default: null
    inputBinding:
      position: 4
      prefix: --preset
    doc: Preset to use [CCS]
    # Alignment modes of --preset:
    #     - "SUBREAD"       -k 19 -w 19    -o 5 -O 56 -e 4 -E 1 -A 2 -B 5 -z 400 -Z 50  -r 2000   -g 5000
    #     - "CCS" or "HIFI" -k 19 -w 19 -u -o 6 -O 26 -e 2 -E 1 -A 1 -B 4 -z 400 -Z 50  -r 2000   -g 5000
    #     - "ISOSEQ"        -k 15 -w 5  -u -o 2 -O 32 -e 1 -E 0 -A 1 -B 2 -z 200 -Z 100 -r 200000 -g 2000 -C 5 -G 200000
    #     - "UNROLLED"      -k 15 -w 15    -o 2 -O 32 -e 1 -E 0 -A 1 -B 2 -z 200 -Z 100 -r 2000   -g 10000

  - id: sample_name
    type: string
    default: null
    inputBinding:
      position: 5
      prefix: --sample
    doc: Sample name. |
         Override the sample name (SM field in RG tag) for all read groups. |
         If not provided, sample names derive from the dataset input |
         with order of precedence - SM field in input read group, |
         biosample name, well sample name, <UnnamedSample>

  # Files <ref.fa> <in.bam> [out.aligned.bam]
  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 6
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

  - id: input_file_reads
    type: File
    inputBinding:
      position: 7
    doc: Input file in native PacBio BAM format, FASTQ, or compressed FASTQ

  - id: output_file_name
    type: string
    default: "out.bam"
    inputBinding:
      position: 8
    doc: Name to use for the output aligned file in BAM format

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: $(inputs.output_file_name)
    secondaryFiles:
      - .bai

doc: |
  Run "pbmm2 align --sort --strip --unmapped [--num-threads <int>] [--sort-threads <int>] [--sort-memory <str>] [--preset <str>] [--sample <str>] <ref.fa> <in.bam> <out.aligned.bam>". |
  Sort the output aligned BAM and generate the corresponding index file
