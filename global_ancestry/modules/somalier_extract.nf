process SOMALIER_EXTRACT {

    tag "${sample_id}"

    conda "${projectDir}/envs/somalier.yml"

    input:
    tuple val(sample_id), path(cram), path(crai)
    tuple path(sites), path(sites_index)
    path fasta

    output:
    tuple val(sample_id), path("${sample_id}.somalier"), emit: somalier_file

    script:
    """
    mkdir -p extract_output

    somalier extract \
        --sites ${sites} \
        --fasta ${fasta} \
        --out-dir extract_output \
        ${cram}

    SOMALIER_FILE=\$(find extract_output -maxdepth 1 -name "*.somalier" | head -1)

    if [ -z "\${SOMALIER_FILE}" ]; then
        echo "ERROR: Somalier extraction did not produce a .somalier file."
        exit 1
    fi

    mv "\${SOMALIER_FILE}" "${sample_id}.somalier"
    """
}