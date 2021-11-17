## svscore_container
provides SVScore (https://github.com/lganel/SVScore)  
  
#### test dokckerhub image runs svscore tests, via singularity:
```
singularity pull docker://wtsihgi/svscore:2.0.0
singularity shell --containall svscore_2.0.0.sif

Singularity> mkdir tests && cp -r $testdir/* tests/ 
Singularity> export testdir=$PWD/tests
Singularity> generateannotations.pl -c 1 -a 2 -b 3 -t 4 -s 5 -e 6 -f 7 -o $testdir $testdir/dummyannotations.bed
Singularity> svscore.pl -f $testdir/dummyannotations.introns.bed -e $testdir/dummyannotations.exons.bed -o max,sum,top2,top2weighted,top3weighted,top4weighted,mean,meanweighted -dvc $testdir/dummyCADD.tsv.gz -i $testdir/stresstest.vcf > $testdir/stresstest.svscore.test.vcf
```

#### set up
https://github.com/lganel/SVScore#first-time-setup

```
wget https://krishna.gs.washington.edu/download/CADD/v1.3/whole_genome_SNVs.tsv.gz 
wget https://krishna.gs.washington.edu/download/CADD/v1.3/whole_genome_SNVs.tsv.gz.tbi
```
