# WGS Microbe - South Africa Polony Project

This repository contains a **whole-genome sequencing (WGS) analysis pipeline** for bacterial genomes from South Africa polony samples.  
The workflow is implemented as a single Bash script: [`WGSMICROBE-SOUTHAfri.sh`](WGSMICROBE-SOUTHAfri.sh).

---

## Pipeline Overview

The pipeline performs the following steps:

1. **Setup & Data Retrieval**
   - Create project directories
   - Download genome sequence data (FASTQ files)

2. **Quality Control & Preprocessing**
   - Perform quality checks with **FastQC** and **MultiQC**
   - Trim reads with **fastp**
   - Repair disordered reads with `repair.sh`

3. **De novo Assembly**
   - Assemble genomes using **SPAdes**
   - Resume or rerun failed assemblies

4. **Genome Annotation & Analysis**
   - Run **BLAST** on assembled contigs
   - Assess assembly quality with **QUAST**

5. **Antimicrobial Resistance (AMR) Genes**
   - Detect AMR genes using **ABRicate** with the **CARD** database
   - Summarize AMR results across all assemblies

6. **Virulence & Toxin Genes**
   - Screen assemblies with **VFDB** (Virulence Factor Database) using **ABRicate**
   - Generate summary reports

---

## Usage

Clone the repository and make the script executable:

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
chmod +x WGSMICROBE-SOUTHAfri.sh
```

Run the full pipeline:

```bash
./WGSMICROBE-SOUTHAfri.sh
```

---

## Output

The script generates the following directories and outputs:

- `data/` â†’ downloaded FASTQ files  
- `quality_control/` â†’ FastQC + MultiQC reports  
- `trim/` â†’ trimmed reads (fastp outputs)  
- `repaired/` â†’ repaired reads  
- `assembly/` â†’ SPAdes assemblies  
- `quast_results/` â†’ QUAST assembly reports  
- `ARG/` â†’ AMR gene reports (ABRicate + CARD)  
- `toxins/` â†’ virulence/toxin gene reports (ABRicate + VFDB)  

---

## Requirements

The following tools must be installed and available in your PATH:

- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)  
- [MultiQC](https://multiqc.info/)  
- [fastp](https://github.com/OpenGene/fastp)  
- [BBTools (repair.sh)](https://jgi.doe.gov/data-and-tools/bbtools/)  
- [SPAdes](https://github.com/ablab/spades)  
- [BLAST+](https://blast.ncbi.nlm.nih.gov/Blast.cgi)  
- [QUAST](http://quast.sourceforge.net/)  
- [ABRicate](https://github.com/tseemann/abricate) with CARD & VFDB databases  

---

## Citation

If you use this pipeline in your research, please cite the relevant tools and databases:

- SPAdes, FastQC, MultiQC, fastp, BBTools, BLAST+, QUAST, ABRicate  
- CARD (Comprehensive Antibiotic Resistance Database)  
- VFDB (Virulence Factor Database)  

---

## » Author

Developed by **Fuhad Lawal** as part of WGS Microbe internship project (HackBio 2025).  
