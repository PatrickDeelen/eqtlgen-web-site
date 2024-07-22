# eQTLgen interaction analysis

Test for interaction of the eQTL effect.

## Parameters

### Input data

Most of these files are either already used by the eQTLgen phase 2 cookbook DataQC or imputation pipeline.

- `vcf_dir` - full path to the folder with imputed filtered vcf files produced by eQTLGen imptutation pipeline "2_Imputation" step (postimpute folder)

- `raw_expfile` - raw expression data (same as input to DataQC step)

- `norm_expfile` - normalized expression data (output of the DataQC step)

- `gte` - genotype to expression coupling file

- `covariates` - File that contains cohort covariates: E.g. sex and age. Sample ids should be the same as in the genotype data

- `exp_platform` - TODO list options (RNAseq)

- `cohort_name` - TODO seems to be unused

- `covariate_to_test` - TODO this needs to be predefined list

- `qtls_to_test` - list of eQTLs to test for interaction, contains the *cis* and *trans* eqtls found by eQTLgen

- `genotype_pcs` - The genotypes PCs as calculated by the DataQC (GenotypePCs.txt)

- `chunk_file` - Chuck file used to create smaller jobs for calculations

- `outdir` - Folder with the results that should be uploaded for the meta-analysis

- `run_stratified` -

- `preadjust` -

- `cell_perc_interactions` -

### Other settings

- `resume` - flag to allow restarting the pipeline without rerunning successfully completed tasks.

- `profile` - should typically be set to "singularity,slurm"
