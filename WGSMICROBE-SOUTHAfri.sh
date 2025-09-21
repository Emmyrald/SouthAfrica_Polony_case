#!/bin/bash

#shebang

#!/bin/bash


mkdir -p data && cd data

wget  -nc -N https://raw.githubusercontent.com/HackBio-Internship/2025_project_collection/refs/heads/main/SA_Polony_100_download.sh

grep "^curl" SA_Polony_100_download.sh | head -n 50 | bash

cd ../
# Create the output folder

mkdir -p quality_control

fastqc data/*.fastq.gz -o quality_control/

multiqc quality_control/ -o quality_control
# Creating a trim folder

mkdir -p trim
# looping through the raw_reads  files available in data/
for file in data/*_1.fastq.gz; do
      #Extracting the file names for fastp
      sample=$(basename "$file" _1.fastq.gz)
      echo "Processing: $sample"
      #Trimming the files using fastp
      fastp \
          -i "data/${sample}_1.fastq.gz" \
          -I "data/${sample}_2.fastq.gz" \
          -o "trim/${sample}_1.fastq.gz" \
          -O "trim/${sample}_2.fastq.gz" \
          --html "trim/${sample}_fastp.html" \
          --json "trim/${sample}_fastp.json"
done
mkdir -p repaired
for file in data/*_1.fastq.gz; do
    # Removing the suffix of the base file
    sample=$(basename "$file" _1.fastq.gz)
   #Repairing paired end reads with repair.sh
   repair.sh in1="trim/${sample}_1.fastq.gz" in2="trim/${sample}_2.fastq.gz" \
    out1="repaired/${sample}_1_rep.fastq.gz"
    out2="repaired/${sample}_2_rep.fastq.gz" \
    outsingle="repaired/${sample}_single.fq"

done
#make directory assembly

mkdir -p assembly

for files in trim/*_1.fastq.gz; do
    file=$(basename "$files" _1.fastq.gz)
    # Denovo assembly using spades.py
    echo "Running SPAdes.py for: ${file}"
    spades.py -1 "trim/${file}_1.fastq.gz" -2 "trim/${file}_2.fastq.gz" -o "assembly/${file}"

done
for file in trim/*_1.fastq.gz; do    
    sample=$(basename "$file" _1.fastq.gz)
    outdir="assembly/${sample}"    
    if [ -f "${outdir}/contigs.fasta" ]; then        
        echo " ${sample} complete. Skipping."        
        continue    
    fi    

    if [ -d "${outdir}" ]; then        
        echo " Resuming SPAdes for ${sample}..."
        spades.py --continue -o "${outdir}"    
    else        
        echo " Starting fresh SPAdes for ${sample}..."
        spades.py \            
        --phred-offset 33 \            
        -1 "trim/${sample}_1.fastq.gz" \            
        -2 "trim/${sample}_2.fastq.gz" \            
        -o "${outdir}"    
    fi
done
for contig in assembly/*/contigs.fasta; do    
    # Get the sample name (the folder name containing contigs.fasta)    
    sample=$(basename "$(dirname "$contig")")    
    echo "Running BLAST for $sample ..."    
    blastn -query "$contig" \        
    -db nt -remote \        
    -out "assembly/${sample}/${sample}_blast_results.txt" \ 
     -outfmt "6 qseqid sseqid pident length evalue stitle" \
     -max_target_seqs 5    
    echo "BLAST completed for $sample. Results saved in ${sample}_blast_results.txt"

done


mkdir -p quast_result

quast.py assembly/*/contigs.fasta -o quast_results


mkdir -p ARG

# Loop through Assembly/
for f in assembly/*/contigs.fasta
do
    sample=$(basename $(dirname $f))
    abricate --db card "$f" > "ARG/${sample}_amr.tsv"
done
abricate --summary ARG/*.tsv > ARG/amr_summary.tsv
mkdir -p toxins

# make sure abricate databases are installed (once)
abricate --setupdb

# loop over assemblies and screen with VFDB
for f in assembly/*/contigs.fasta; do
  sample=$(basename "$(dirname "$f")")
  abricate --db vfdb "$f" > "toxins/${sample}_vfdb.tsv"
done

# summary across all
abricate --summary toxins/*_vfdb.tsv > toxins/vfdb_summary.tsv
