version 1.0

import "wdl/main.wdl" as main

workflow sra_prefetch_workflow {
  input {
    File srr_list_file
    File ngc_file
    String output_directory
  }

  call main.sra_prefetch_from_list {
    input:
      srr_list_file = srr_list_file,
      ngc_file = ngc_file,
      output_directory = output_directory
  }

  output {
    Array[File] fastq_files = sra_prefetch_from_list.fastq_files
  }
}

