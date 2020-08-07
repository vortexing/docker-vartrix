version 1.0

workflow vartrix {
  input {
  }
  File vcf = "s3://fh-pi-paguirigan-a/ReferenceDataSets/cb_Sniffer/cell-line-variants-cbsniffer.tsv"
  File cellRangerBam = "/fh/scratch/delete90/paguirigan_a/svelazqu/stagedInputs/countOCItrial1/outs/possorted_genome_bam.bam"
  File fasta = "/fh/fast/paguirigan_a/pub/ReferenceDataSets/genome_data/human/hg38/Homo_sapiens_assembly38.fasta"
  File fastaIndex = "/fh/fast/paguirigan_a/pub/ReferenceDataSets/genome_data/human/hg38/Homo_sapiens_assembly38.fasta.fai"
  File barcodes = "s3://fh-pi-paguirigan-a/tg/SR/ngs/illumina/apaguiri/191126_A00613_0081_BHJ2CLDRXX/cellranger/count/countOCItrial1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"
  String vartrixDocker = "vortexing/vartrix:v1.1.16"
  call vartix {
    input:
      vcf = vcf,
      cellRangerBam = cellRangerBam,
      fasta = fasta,
      fastaIndex = fastaIndex,
      barcodes = barcodes,
      threads = 4,
      taskDocker = vartrixDocker
  }
  output {

  }
}

task vartrix {
  input {
    File vcf
    File cellRangerBam
    File fasta
    File fastaIndex
    File barcodes
    Int threads
    String taskDocker
  }
  command {
    set -eo pipefail
    gunzip -c ~{barcodes} > barcodes.tsv
    ./vartrix \
      -v ~{vcf} \
      -b ~{cellRangerBam} \
      -f ~{fasta} \
      -c barcodes.tsv \
      --threads ~{threads}
  }
  output {

  }
  runtime {
    cpu: threads
    docker: taskDocker
  }
}