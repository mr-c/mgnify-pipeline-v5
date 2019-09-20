class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_file: File
  gathering_bit_score: boolean
  name_database: string
  data: Directory
  omit_alignment: boolean

outputs:
  hmmscan_result:
    type: File
    outputSource: combine_hmm/result

steps:

  split_seqs:
    run: ../chunks/fasta_chunker.cwl
    in:
      seqs: input_file
      chunk_size: { default: 10 }
    out: [ chunks ]

# << Functional annotation. hmmscan >>
  hmmscan:
    scatter: input_file
    run: hmmscan-subwf.cwl
    in:
      input_file: split_seqs/chunks
      gathering_bit_score: gathering_bit_score
      name_database: name_database
      data: data
      omit_alignment: omit_alignment
    out: [ hmm_result ]

# << Unite hmmscan >>
  combine_hmm:
    run: ../chunks/concatenate.cwl
    in:
      files: hmmscan/hmm_result
      outputFileName: { default: 'hmm_united' }
    out: [ result ]
    label: "combined chunked hmmscam outputs"

# << Add header >>