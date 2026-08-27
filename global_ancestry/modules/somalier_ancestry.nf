process SOMALIER_ANCESTRY {

    tag "${sample_id}"

    conda "${projectDir}/envs/somalier.yml"

    input:
    tuple val(sample_id), path(sample_somalier)
    path reference_somalier
    path ancestry_labels

    output:
    path "${sample_id}_ancestry*"

    script:
    """
    somalier ancestry \
        --labels ${ancestry_labels} \
        --n-pcs 10 \
        -o ${sample_id}_ancestry \
        ${reference_somalier}/*.somalier \
        ++ \
        ${sample_somalier}
    """
}