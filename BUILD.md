# MEdical Sequence Analysis Pipeline (MESAP) Build Instructions
Following are instructions to build/update the MESAP package for both the Singularity and Docker container platforms, and to build/update the reference mesap_data.  **Whenever you would like to upgrade software in the pipelines, or to add new components or tools, you will need rebuild MESAP. Whenever you wish to upgrade the reference data files, you also need to rebuild MESAP** (as the versions and names of reference data files are tied to the pipelines via environment variables).

## 1. Clone the MESAP repository from GitHub
Firstly, grab the latest version of the MESAP code from the github home, using either the git command or by downloading the repository as a .zip from [Github](https://github.com/kim-carter/mesap.git).

~~~{.bash}
git clone https://github.com/kim-carter/mesap.git
¬¬¬

## 2. (optional) Make changes to MESAP software as required
If you are making changes to the software versions in the pipelines, once you have checked out the git repository, you should follow standard git process eg as described [here](https://guides.github.com/introduction/git-handbook/) to commit and log changes to the repository.

Everything is created from the [Dockerfile](Dockerfile), which sets up the container for running everything in, including installing each of the tools used in each of the pipelines.  If you wish to add new version of tools (or just add new tools), you should follow the documented examples in the Dockerfile, which illustrate how to unzip/install each tool and get ready to run.

Also in the Docke



## 3. Build the Docker image
Once you have a copy of the MESAP files you can build the image for docker use, which also serves as a basis for the singularity image. To run this command, you will need to have [docker](https://www.docker.com) installed.

~~~{.bash}
cd mesap
docker build -t mesap:3.0 . 
~~~
Note: *mesap:3.0* is the tag assigned to the built docker image. If you make changes to MESAP, then using the different tag versions (eg 3.0 vs 3.1 etc) capture when changes are made.

## 4. Build the Singularity image
Once you have built the Docker image for MESAP, you can build the image for Singularity use. To run this command, you will need to have [singularity](https://github.com/hpcng/singularity/releases) installed.

~~~{.bash}
singularity build mesap_3.0.sif docker-daemon://mesap:3.0
~~~

Note: *mesap:3.0* is the tag assigned to the built docker image - change this to match the tag you've assigned.
Note: *mesap_3.0.sif* is the name of the singularity binary you've just created (this can be changed of course)

## What reference / annotation files that the pipelines use?
We've bundled up all of the necessary genome sequence and annotation files for each of the Human, Mouse and Rat pipelines to ensure that the pipelines and reference data files themselves are repeatable and reproducible.  The descriptions of how the data files were created are detailed elsewhere in the mesap_data git repository, and are summarised below.

Reference files included in **version 2.0** are:
- for the Human pipeline we are using the HG19/GRCH37 genome build from UCSC, along with the Gencode GTF annotation (https://www.gencodegenes.org/releases/) version 19 (to most recent vuild for HG19 available) using level 1 & 2 trancripts only, supplemented with genome annotation from Ensembl 75 (the last HG19 release for Ensembl)
- for the Mouse pipeline we are using the MM11/GRCm38.p5 genome build from Sanger/Gencode, along with the Gencode GTF annotation (https://www.gencodegenes.org/releases/) version M12 using level 1 & 2 trancripts only, supplemented with genome annotation from Ensembl 87 (the latest release for MM11).
- for the Rat pipeline we are using the RN6 genome build from Ensembl, along with the Ensembl GTF annotation details from Ensembl 87 (the latest release for RN6).

