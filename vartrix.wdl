version 1.0

workflow vartrix_tests {
  input {
  }
  ### UGH.  This vcf has chromosomes as "chr1", rather than "1", so it breaks.  But otherwise this works. 
  File vcf = "s3://fh-pi-paguirigan-a/tg/TGR-Analyses/Panel_BWA_HC_Mutect_Samtools_AnnotatedVariants/7486e000-62e4-4308-b69a-711ada2cbfa5/M00000513/OCI-AML3_M00000513.hg38.mutect2.hg38_multianno.vcf"
  File cellRangerBam = "/fh/scratch/delete90/paguirigan_a/svelazqu/stagedInputs/countOCItrial1/outs/possorted_genome_bam.bam"
  File cellRangerBai = "/fh/scratch/delete90/paguirigan_a/svelazqu/stagedInputs/countOCItrial1/outs/possorted_genome_bam.bam.bai"
  File fasta = "/fh/fast/paguirigan_a/pub/ReferenceDataSets/genome_data/human/hg38/Homo_sapiens_assembly38.fasta"
  File fastaIndex = "/fh/fast/paguirigan_a/pub/ReferenceDataSets/genome_data/human/hg38/Homo_sapiens_assembly38.fasta.fai"
  File barcodes = "s3://fh-pi-paguirigan-a/tg/SR/ngs/illumina/apaguiri/191126_A00613_0081_BHJ2CLDRXX/cellranger/count/countOCItrial1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"
  # Software/Modules/Docker
  String vartrixDocker = "vortexing/vartrix:v1.1.16"
  String samtoolsModule = "SAMtools/1.10-GCCcore-8.3.0"
   call convertCellRangerDict {
    input:
      cellRangerBam = cellRangerBam,
      taskModules = samtoolsModule,
      threads = 8
  }
  call vartrix {
    input:
      vcf = vcf,
      cellRangerBam = convertCellRangerDict.convertedBam,
      cellRangerBai = convertCellRangerDict.convertedBai,
      fasta = fasta,
      fastaIndex = fastaIndex,
      barcodes = barcodes,
      threads = 4,
      taskDocker = vartrixDocker
  }
}

task vartrix {
  input {
    File vcf
    File cellRangerBam
    File cellRangerBai
    File fasta
    File fastaIndex
    File barcodes
    Int threads
    String taskDocker
  }
  command {
    set -eo pipefail
    gunzip -c ~{barcodes} > barcodes.tsv
    vartrix \
      -v ~{vcf} \
      -b ~{cellRangerBam} \
      -f ~{fasta} \
      -c barcodes.tsv \
      --threads ~{threads}
  }
  runtime {
    cpu: threads
    docker: taskDocker
  }
}

task convertCellRangerDict {
  input {
    File cellRangerBam
    String taskModules
    Int threads
  }
    String filename = basename(cellRangerBam, ".bam")
  command {
    set -eo pipefail
    samtools view -H ~{cellRangerBam} | \
      sed -e 's/SN:\([0-9XY]\)/SN:chr\1/' -e 's/SN:MT/SN:chrM/' |
      samtools reheader - ~{cellRangerBam} > ~{filename}.converted.bam

    samtools index -@ ~{threads} ~{filename}.converted.bam
  }
  output {
    File convertedBam = "~{filename}.converted.bam"
    File convertedBai = "~{filename}.converted.bam.bai"
  }
  runtime {
    modules: taskModules
    cpu: threads
  }
}