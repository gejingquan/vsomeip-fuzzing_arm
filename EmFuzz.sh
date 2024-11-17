#!/bin/bash

job_corpus=$1
job_fuzz_target_path=$2
job_parallel_threads=$3
job_name=$4
job_output=$5
job_fuzzer_identifier=$6
job_dictionary=$7

echo ==============================================
echo job_corpus is            :$job_corpus
echo job_fuzz_target_path is  :$job_fuzz_target_path
echo job_parallel_threads is  :$job_parallel_threads
echo job_name is              :$job_name
echo job_output is            :$job_output
echo job_fuzzer_identifier    :$job_fuzzer_identifier
echo job_dictionary is        :$job_dictionary
echo ==============================================


cp $job_corpus/library/*  /fuzz/lib/     
afl-fuzz -i $job_corpus -o $job_output -Q -S $job_fuzzer_identifier -- $job_fuzz_target_path @@
