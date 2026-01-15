#!/bin/bash

path_to_fastq_pass="/data/HEV/2026-01-06_HEV3/20260106_1458_X3_FBE75899_b9e356a8/fastq_pass"

RED='\033[0;31m'
NC='\033[0m'

for i in barcode{01..50}
do
        FILE_NO=$(ls -l ${path_to_fastq_pass}/${i}/*fastq.gz | wc -l)
        echo -e "${RED}Found ${FILE_NO} fastq.gz files for barcode ${i}${NC}"
        echo -e "${RED}Running prechop and chopper on ${i}${NC}"
        source /data/miniconda3/bin/activate nanoplot
        porechop -i ${path_to_fastq_pass}/${i} -t 12 > ${i}_porechop.fastq
        gzip -f ${i}_porechop.fastq
        chopper --maxlength 500 --minlength 300 --headcrop 35 --tailcrop 35 --threads 4 -i ${i}_porechop.fastq.gz > ${i}_pore_trim.fastq
        gzip -f ${i}_pore_trim.fastq
        conda deactivate
        source /data/miniconda3/bin/activate ampli_clean
        ampli_clean -f ${i}_pore_trim.fastq.gz -r /data/HEV_resources/references/HEV_GenBank.fasta --map-only -o ${i} --wtia
        conda deactivate
done


source /data/miniconda3/bin/activate artic
for i in barcode{01..50}
do
        echo -e "${RED}Working on ${i} consensus sequence...${NC}"
        filename=$(basename ${i}*.sorted.bam)
        tmp=${filename#*_}
        ref=${tmp%.sorted*}
        #This conditional checks if a sorted bam file exists for the barcode in question
        if [[ $ref != barcode* ]]; then echo "${i},${ref},${count}";
                medaka consensus --model r1041_e82_400bps_hac_v4.2.0 --threads 4 --chunk_len 800 --chunk_ovlp 400 ${i}_${ref}.sorted.bam ${i}.hdf
                medaka variant ./ref_${ref}.fasta ./${i}.hdf ${i}.vcf
                medaka tools annotate --pad 25 ${i}.vcf ./ref_${ref}.fasta ${i}_${ref}.sorted.bam ${i}_annotated.vcf
                artic_vcf_filter --medaka ${i}_annotated.vcf ${i}.pass.vcf ${i}.fail.vcf
                bgzip -f ${i}.pass.vcf
                tabix -p vcf ${i}.pass.vcf.gz
                maskara -d 20 -r ${ref} -o ${i}_mask ${i}_${ref}.sorted.bam
                bcftools consensus -f ./ref_${ref}.fasta ${i}.pass.vcf.gz -m ${i}_mask.tsv -o ${i}_${ref}.consensus.fasta
                sed -i "s@${ref}@${i}@g" ${i}_${ref}.consensus.fasta
        fi
done

echo DONE!
