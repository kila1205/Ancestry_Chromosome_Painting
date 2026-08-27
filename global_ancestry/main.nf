nextflow.enable.dsl=2

include { VALIDATE_INPUT }    from './modules/validate_input'
include { SOMALIER_EXTRACT }  from './modules/somalier_extract'
include { SOMALIER_ANCESTRY } from './modules/somalier_ancestry'


params.input = null

params.sites =
    "${projectDir}/resources/sites.hg38.vcf.gz"

params.sites_index =
    "${projectDir}/resources/sites.hg38.vcf.gz.tbi"

params.fasta =
    "/path/to/Homo_sapiens_assembly38.fasta"

params.reference =
    "${projectDir}/resources/1kg/1kg-somalier"

params.labels =
    "${projectDir}/resources/ancestry-labels-1kg.tsv"

params.outdir =
    "${projectDir}/results"


workflow {

    if (!params.input) {
        error """
        Missing required parameter: --input

        Expected CSV format:

        sample_id,cram,crai
        SAMPLE01,/path/sample.cram,/path/sample.cram.crai
        """
    }

    input_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.sample_id,
                file(row.cram),
                file(row.crai)
            )
        }

    sites_ch = Channel.value(
        tuple(
            file(params.sites),
            file(params.sites_index)
        )
    )

    fasta_ch = Channel.value(
        file(params.fasta)
    )

    VALIDATE_INPUT(
        input_ch,
        sites_ch
    )

    SOMALIER_EXTRACT(
        VALIDATE_INPUT.out.validated_sample,
        sites_ch,
        fasta_ch
    )

    reference_ch = Channel.value(
        file(params.reference)
    )

    labels_ch = Channel.value(
        file(params.labels)
    )

    SOMALIER_ANCESTRY(
        SOMALIER_EXTRACT.out.somalier_file,
        reference_ch,
        labels_ch
    )
}