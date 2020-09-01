# MEdical Sequence Analysis Pipeline (MESAP) Build Instructions
Following are instructions to build/update the MESAP package for both the Singularity and Docker container platforms, and to build/update the reference mesap_data.  **Whenever you would like to upgrade software in the pipelines, or to add new components or tools, you will need rebuild MESAP. Whenever you wish to upgrade the reference data files, you also need to rebuild MESAP** (as the versions and names of reference data files are tied to the pipelines via environment variables).

## 1. Clone the MESAP repository from GitHub
Firstly, grab the latest version of the MESAP code from the github home, using either the git command or by downloading the repository as a .zip from [Github](https://github.com/kim-carter/mesap.git).

~~~{.bash}
git clone https://github.com/kim-carter/mesap.git
~~~

## 2. (optional) Make changes to MESAP software as required
If you are making changes to the software versions in the pipelines, once you have checked out the git repository, you should follow standard git process eg as described [here](https://guides.github.com/introduction/git-handbook/) to commit and log changes to the repository.

Everything is created from the [Dockerfile](Dockerfile), which sets up the container for running everything in, including installing each of the tools used in each of the pipelines.  If you wish to add new version of tools (or just add new tools), you should follow the documented examples in the Dockerfile, which illustrate how to unzip/install each tool and get ready to run. Programs should be located in the *programs* subfolder for example.

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

## 5. (optional) Build the mesap_data reference data
Once you have built the Docker and Singularity images for MESAP, you also need to have the mesap_data folder containing the reference sequences and annotations.  In the Dockerfile are the environment variables used to configure the annotation and reference files used for each pipeline. 

For example, the ones relevant to the human pipeline are:
~~~{.bash}
ENV HUMAN_INDEX=/mesap_data/human/GRCh38
ENV HUMAN_GENOME=/mesap_data/human/GRCh38.primary_assembly.genome.fa
ENV HUMAN_GTF=/mesap_data/human/gencode.v34.annotation.gtf
ENV HUMAN_SPLICE=/mesap_data/human/human_splice
ENV HUMAN_EXON=/mesap_data/human/human_exon
ENV HUMAN_ENSMAP=/mesap_data/human/Biomart_E100_human.txt
~~~

Should any changes need to occur to the MESAP reference data, then there should be corresponding updates to the environment variables defined in the Dockerfile, plus the new files should then be copied to the new reference data folders.

### Script to populate mesap_data
The script to download and generate all of the mesap_data data for MESAP 3.0 is located in [scrips/mesap_databuild.sh](https://github.com/kim-carter/mesap/blob/master/scripts/mesapdata_build.sh).   Please note, at the present moment the script does not explictly create the necessary directories for each species ie once the build script is run, you have to manually copy all of the human related data files to a subdir called "human" (and so on for mouse and rat).

Please note: the HISAT aligner index building process requires very large abouts of system memory - in excess of 200-300GB of RAM for the human and mouse genones for examples.
