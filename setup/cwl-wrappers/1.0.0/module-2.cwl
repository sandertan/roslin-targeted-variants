cwlVersion: v1.0
class: Workflow
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}

inputs:
    bams:
        type:
            type: array
            items: File
        secondaryFiles:
            - .bai
    fasta: string
    hapmap:
        type: File
        secondaryFiles:
            - .idx    
    dbsnp:
        type: File
        secondaryFiles:
            - .idx
    indels_1000g:
        type: File
        secondaryFiles:
            - .idx    
    snps_1000g:
        type: File
        secondaryFiles:
            - .idx    
    rf: string[]
    fci_file: string
    num_cpu_threads_per_data_thread: string
    covariates: string[]
    abra_scratch: string
    recal_file: string
    emit_original_quals: boolean

outputs:
    covint_list:
        type:
            type: array
            items: File
        outputSource: gatk_find_covered_intervals/fci_list
#    covint_bed:
#        type:
#            type: array
#            items: File
#        outputSource: group_process/fci_bed
    bams:
        type:
            type: array
            items: File
        outputSource: parallel_printreads/out

steps:
    gatk_find_covered_intervals:
        run: ./cmo-gatk.FindCoveredIntervals/3.3-0/cmo-gatk.FindCoveredIntervals.cwl
        in:
            reference_sequence: fasta
            input_file: bams
            out: fci_file
        out: [fci_list]

    list2bed:
        run: ./cmo-list2bed/1.0.0/cmo-list2bed.cwl
        in:
            input_file: gatk_find_covered_intervals/fci_list
            output_file:
                valueFrom: |
                    ${ return inputs.input_file.basename.replace( ".list", ".bed"); }
        out: [output_file]
    abra:
        run: ./cmo-abra/0.92/cmo-abra.cwl
        in:
            in: bams
            ref: fasta
            out:
                valueFrom: |
                    ${ return inputs.in.map(function(x){ return x.nameroot + ".abra.bam"; }); }
            working: abra_scratch
            targets: list2bed/output_file
        out: [out]

    parallel_fixmate:
        in:
            I: abra/out
        out: [out]
        scatter: [I]
        scatterMethod: dotproduct
        run:
            class: Workflow
            inputs:
                I:
                    type:
                        type: array
                        items: File
            outputs:
                out:
                    type:
                        type: array
                        items: File
                    outputSource: picard_fixmate_information/out_bam
            steps:
                picard_fixmate_information:
                    run: ./cmo-picard.FixMateInformation/1.96/cmo-picard.FixMateInformation.cwl
                    in:
                        I: I
                        O:
                            valueFrom: |
                                  ${ return inputs.I.basename.replace(".bam",".fmi.bam") }
                    out: [out_bam]

    gatk_base_recalibrator:
        run: ./cmo-gatk.BaseRecalibrator/3.3-0/cmo-gatk.BaseRecalibrator.cwl
        in:
            reference_sequence: fasta
            input_file: parallel_fixmate/out
            knownSites: [dbsnp, hapmap, indels_1000g, snps_1000g]
            covariate: covariates
            out: recal_file
        out: [recal_matrix]

    parallel_printreads:
        in:
            input_file: parallel_fixmate/out
            reference_sequence: fasta
            BQSR: gatk_base_recalibrator/recal_matrix
            num_cpu_threads_per_data_thread: num_cpu_threads_per_data_thread
        out: [out]
        scatter: [input_file]
        scatterMethod: dotproduct
        run:
            class: Workflow
            inputs:
                input_file:
                    type:
                        type: array
                        items: File
                reference_sequence:
                    type: string
                BQSR:
                    type: File
                num_cpu_threads_per_data_thread:
                    type: string
            outputs:
                out:
                    type:
                        type: array
                        items: File
                    outputSource: gatk_print_reads/out_bam
            steps:
                gatk_print_reads:
                    run: ./cmo-gatk.PrintReads/3.3-0/cmo-gatk.PrintReads.cwl
                    in:
                        reference_sequence: reference_sequence
                        BQSR: BQSR
                        input_file: input_file
                        num_cpu_threads_per_data_thread: num_cpu_threads_per_data_thread
                        out:
                            valueFrom: |
                                ${ return inputs.input_file.basename.replace( ".bam", ".printreads.bam");}

                    out: [out_bam]