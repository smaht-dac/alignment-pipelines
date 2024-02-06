#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/methylink:VERSION

baseCommand: [methylink]

arguments: [--tmp, '.']

inputs:
  - id: input_file_bam
    type: File
    inputBinding:
      prefix: --aln
    doc: Aligned BAM file to link the tags to
         Must be sorted by genomic coordinates

  - id: methyl_file_bam
    type: File
    inputBinding:
      prefix: --methyl_bams
    doc: Unaligned BAM file with the tags to use

  - id: nthreads
    type: int
    default: null
    inputBinding:
      prefix: --threads
    doc: Number of threads to use

  - id: tmp_prefix
    type: string
    default: "SAMPLE"
    inputBinding:
      prefix: --sample
    doc: Name to use in the prefixing

  - id: output_file_name
    type: string
    default: "linked.bam"
    inputBinding:
      prefix: --output
    doc: Name to use for the output file in BAM format with linked tags

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: $(inputs.output_file_name)
    secondaryFiles:
      - .bai

doc: |
  Run methylink to carry over tags for ONT data from unaligned |
  to target BAM file.
