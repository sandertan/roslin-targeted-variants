#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: cmo-list2bed.cwl
doap:release:
- class: doap:Version
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_list2bed -o FILENAME --generate_cwl_tool
# Help: $ cmo_list2bed  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- sing.sh
- list2bed
- 1.0.0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 2
    coresMin: 1


doc: |
  rerun a FIZZLED Job

inputs:
  input_file:
    type: 

      - string
      - File
      - type: array
        items: string
    doc: picard interval list
    inputBinding:
      prefix: --input_file

  output_file:
    type: string

    doc: output bed file
    inputBinding:
      prefix: --output_file

  no_sort:
    type: ['null', string]
    default: store_false
    doc: sort bed file output
    inputBinding:
      prefix: --no_sort


outputs:
  output_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_file)
            return inputs.output_file;
          return null;
        }