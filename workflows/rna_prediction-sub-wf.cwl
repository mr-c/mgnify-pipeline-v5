#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
  input_sequences: File
  silva_ssu_database:
    type: File
    secondaryFiles: [.mscluster]
  silva_lsu_database:
    type: File
    secondaryFiles: [.mscluster]
  silva_ssu_taxonomy: File
  silva_lsu_taxonomy: File
  silva_ssu_otus: File
  silva_lsu_otus: File
  ncRNA_ribosomal_models: File[]
  ncRNA_ribosomal_model_clans: File
  pattern_SSU: string
  pattern_LSU: string
  pattern_5S: string
  output_filename_ssu: string
  output_filename_lsu: string
  output_filename_5s: string


outputs:
  ncRNAs:
    type: File
    outputSource: find_ribosomal_ncRNAs/deoverlapped_matches

steps:

  index_reads:
    run: ../tools/easel/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences_with_index ]

# cmsearch -> concatinate -> deoverlap
  find_ribosomal_ncRNAs:
    run: cmsearch-multimodel-wf.cwl
    in:
      query_sequences: input_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ cmsearch_matches, concatenate_matches, deoverlapped_matches ]

#  extract coords -> esl-sfetch
  extract_sequences_SSU:
    run: ../tools/RNA_prediction/get-extract-subwf.cwl
    in:
      input_file: hack/moved_file
      input_pattern: pattern_SSU
      index_reads: index_reads/sequences_with_index
    out: [ finalOutFiles ]

