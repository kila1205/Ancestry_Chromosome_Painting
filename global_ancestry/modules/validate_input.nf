process VALIDATE_INPUT {

    tag "${sample_id}"

    input:
    tuple val(sample_id), path(cram), path(crai)
    tuple path(sites), path(sites_index)

    output:
    tuple val(sample_id), path(cram), path(crai), emit: validated_sample

    script:
    """
    echo "========================================"
    echo " Ancestry Pipeline - Input Validation"
    echo "========================================"
    echo "Sample       : ${sample_id}"
    echo "CRAM         : ${cram}"
    echo "CRAI         : ${crai}"
    echo "Sites VCF    : ${sites}"
    echo "Sites index  : ${sites_index}"
    echo ""

    test -s "${cram}" || {
        echo "ERROR: CRAM file is missing or empty."
        exit 1
    }

    test -s "${crai}" || {
        echo "ERROR: CRAI file is missing or empty."
        exit 1
    }

    test -s "${sites}" || {
        echo "ERROR: Somalier sites VCF is missing or empty."
        exit 1
    }

    test -s "${sites_index}" || {
        echo "ERROR: Somalier sites VCF index is missing or empty."
        exit 1
    }

    echo "Input files successfully validated."
    """
}