version 1.0

workflow sra_prefetch_from_list {
  input {
    File srr_list_file
    File ngc_file
    String output_directory
    Int disk_gb = 100
  }

  call prefetch_sra {
    input:
      srr_list_file = srr_list_file,
      ngc_file = ngc_file,
      disk_gb = disk_gb
  }

  call convert_to_fastq {
    input:
      sra_files = prefetch_sra.output_files,
      ngc_file = ngc_file,
      output_directory = output_directory,
      disk_gb = disk_gb
  }

  output {
    Array[File] fastq_files = convert_to_fastq.fastq_outputs
  }
}

task prefetch_sra {
  input {
    File srr_list_file
    File ngc_file
    Int disk_gb
  }

  command {
    set -e -o pipefail

    mkdir -p sra_downloads

    while IFS= read -r SRR_ID; do
      echo "Downloading $SRR_ID"
      prefetch --ngc ~{ngc_file} --output-directory sra_downloads "$SRR_ID"
    done < ~{srr_list_file}
  }

  output {
    Array[File] output_files = glob("sra_downloads/*.sra")
  }

  runtime {
    docker: "custom/sra-tools-gcs:latest"
    memory: "4 GB"
    cpu: 2
    disks: "local-disk ~{disk_gb} HDD"
  }
}

task convert_to_fastq {
  input {
    Array[File] sra_files
    File ngc_file
    String output_directory
    Int disk_gb
  }

  command <<<
    set -e -o pipefail
    mkdir -p fastq_output

    for sra_file in ~{sep=' ' sra_files}; do
      echo "Converting $sra_file to FASTQ"
      fasterq-dump --ngc ~{ngc_file} --split-files --gzip --outdir fastq_output "$sra_file"
    done

    gsutil -m cp -r fastq_output/* ~{output_directory}/
  >>>

  output {
    Array[File] fastq_outputs = glob("fastq_output/*.fastq.gz")
  }

  runtime {
    docker: "custom/sra-tools-gcs:latest"
    memory: "8 GB"
    cpu: 4
    disks: "local-disk ~{disk_gb} HDD"
  }
}
