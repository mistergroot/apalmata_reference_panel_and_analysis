#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=mpcs_hifmb.p
#SBATCH --time=08:00:00
#SBATCH --job-name=ne_estimate_single

source ~/.bashrc
conda activate orbicella

cd $SLURM_SUBMIT_DIR
INPREFIX=$1
OUTPREFIX=$2
RECOMBRATE=$3
GONEDATATYPE=$4

bcftools view -H ${INPREFIX}.vcf.gz \
    | cut -f1-2 | shuf | head -n 1000000 \
    | sort -k1,1 -k2,2n \
    > ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps.txt
bcftools view -T ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps.txt \
    -o ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned.vcf \
    ${INPREFIX}.vcf.gz

/fs/dss/work/noge4093/dendrogyra_popgen/currentNe2/currentne2 \
    -s 1000000 ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned.vcf \
    -r ${RECOMBRATE} -o ${OUTPREFIX} -t $SLURM_NTASKS

#grep "^#" ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned.vcf \
#    > ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned_onlylargechr.vcf
#grep -v "^#" ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned.vcf \
#    | grep "^OZ" |  grep -v "^OZ076403.1" \
#    >> ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned_onlylargechr.vcf

#/fs/dss/work/noge4093/dendrogyra_popgen/GONE2/gone2 \
#    -g ${GONEDATATYPE} ${OUTPREFIX}_${SLURM_JOB_ID}_random_snps_thinned_onlylargechr.vcf \
#    -s 1000000 -r ${RECOMBRATE} -o ${OUTPREFIX} -t $SLURM_NTASKS
