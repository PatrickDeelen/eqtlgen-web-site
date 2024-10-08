# eQTLgen interaction analysis

Test for interaction of the eQTL effects.


## Downloading the pipeline

If you don't have a new nextflow available it can be downloaded using: 
```
wget https://github.com/nextflow-io/nextflow/releases/download/v24.04.4/nextflow-24.04.4-all
chmod ug+x nextflow-24.04.4-all
```

The pipeline can be obtained using: 
```
wget https://github.com/eQTLGen/eQTLGenInteractions/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
```

Finally, two additional files are needed: 
```
wget https://downloads.molgeniscloud.org/downloads/eqtlgen/interactions/EigenvectorsTop1000.txt.gz
wget https://downloads.molgeniscloud.org/downloads/eqtlgen/interactions/Ica100.txt.gz
```

## Parameters

The 

### Input data

Most of these files are either already used or made by the eQTLgen phase 2 cookbook DataQC or imputation pipeline.

- `vcf_dir` - full path to the folder with imputed filtered vcf files produced by eQTLGen imptutation pipeline "2_Imputation" step (postimpute folder)
- `raw_expfile` - raw expression data (same as input to DataQC step). Genes/Probes on rows and samples on columns. Samples ids as specified on column 2 of the GTE file.
- `norm_expfile` - normalized expression data (output of the DataQC step) samples on rows and Genes/Probes on columns. This file should be use exactly as created by the eQTLgen QCpipeline.
- `gte` - genotype to expression coupling file
- `covariates` - File that contains cohort covariates: E.g. sex and age. Samples on rows and covariates on columns. Sample ids should be the same as in the genotype data (column 1 of the GTE file)
- `exp_platform` - Options: RNAseq; RNAseq_HGNC; HT12v3; HT12v4; HuRef8; AffyU219; AffyHumanExon
- `cohort_name` - TODO seems to be unused
- `genotype_pcs` - The genotypes PCs as calculated by the DataQC (GenotypePCs.txt)

### Other settings

- `outdir` - Folder with the results that should be uploaded for the meta-analysis
- `expression_eigenvectors` - The downloaded file with expression eigenvectors of eQTLgen (EigenvectorsTop1000.txt.gz)
- `expression_ics` - The downloaded file with expression independent components of eQTLgen (Ica100.txt.gz)
- `chunk_file` - Chuck file used to create smaller jobs for calculations
- `covariate_to_test` - TODO this needs to be predefined list
- `qtls_to_test` - list of eQTLs to test for interaction, contains the *cis* and *trans* eqtls found by eQTLgen
- `run_stratified` - Currently not used
- `preadjust` - Flag to first regress out non-tested covariates
- `cell_perc_interactions` -
- `resume` - flag to allow restarting the pipeline without rerunning successfully completed tasks.
- `profile` - should typically be set to `singularity,slurm`

## Running the pipeline




## Pipeline overview

The chapters below describe in more details what the individuals steps of the pipeline do. This is information
is not needed to run the pipeline.

### NormalizeExpression
First the data needs to be normalized in a different way then currently done for eQTLgen phase 2.
We start with the same raw expression as the eQTLgen dataQC pipeline. Additionally this step uses
the output expression data as normalized by the dataQC pipeline but only to select the samples and
genes that pass the QC.

Below are the procedures as they can be selected using the `exp_platform` option

#### RNAseq

1. Remove samples not in the sample mapping file or in the eQTLgen normalized expression data.
2. Remove genes with no variance.
3. Remove genes with CPM>0.5 in less than 1% of samples.
4. Do TTM normalization using `calcNormFactors` from the `edgeR` package.

#### RNAseq_HGNC

1. Convert to probes to genes using the provided empirical probe mapping files, exclude probes to mapped to a gene.
2. Remove samples not in the sample mapping file or in the eQTLgen normalized expression data.
3. Remove genes with no variance.
4. Remove genes with CPM>0.5 in less than 1% of samples.
5. Do TTM normalization using `calcNormFactors` from the `edgeR` package.

#### HT12v3 HT12v4 HuRef8

1. Convert to probes to genes using the provided empirical probe mapping files, exclude probes to mapped to a gene.
2. Remove samples not in the sample mapping file or in the eQTLgen normalized expression data.
3. Use `normalize.quantiles` from the `preprocessCore` package for Quantile Normalization of the new subset of samples.

#### AffyU219 AffyHumanExon

**Note:** affymetrix based expression data should be pre-normalized instead of raw in the same manner as done previously for eQTLgen

1. Convert to probes to genes using the provided empirical probe mapping files, exclude probes to mapped to a gene.
2. Remove samples not in the sample mapping file or in the eQTLgen normalized expression data.
3. Remove genes with no variance.

### ConvertVcfToPlink & MergePlinkPerChr

By default, the pipeline uses the VCF files as they are created by the eQTLgen imputation pipeline. 
These are converted to plink bed/bim/fam files and then the chromosomes files are concatenated. 

### Prepare_covariates
The prepare covariates step has different substeps

#### CalculateRNAQualityScore
This steps correlates each sample to the average expression of all samples. This 
correlation is an indication of overall quality

#### Deconvolution
The blood cell type composition is estimated using expression patterns. The pipeline is currently
hardcoded to use [dtangle](https://gjhunt.github.io/dtangle/) with the LM22 hematopoietic signatures.

#### CombineCovariatesRNAqual
The predefined covariates, genotype PCs, the GTE (genotype and phenotype expression sample coupling),
blood composition estimated and the RNAseq quality scores are merged into a single table.

### ConvertVcfToPlink & MergePlinkPerChr
Convert the VCF files to bed/bim/fam files and concatenate the different chromosomes. 

### Run_interaction_qtl_mapping
Uses [Limix qtl](https://github.com/single-cell-genetics/limix_qtl?tab=readme-ov-file). 
Optionally does a pre correction of covariates otherwise the covariates are added to the model.

Limix first does a inversion normal transformation of the expression data and then creates a model 
without the interaction term and second model including the interaction effect. 
These two models are then compared using Likelihood Ratio Test. Limix uses 20 permutations 

## Permutation strategy

