#!/bin/bash
#
# Copyright (C) 2010,2011 Timo Lassmann <timolassmann@gmail.com>
#
# This file is part of delve.
#
# Delve is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Delve is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Delve.  If not, see <http://www.gnu.org/licenses/>.
#



INDIR_DIR=
OUTDIR_DIR=
NUMREADS=0


function usage()
{
cat <<EOF
usage: $0  -i <indir> -o <outdir> -n <number of reads
EOF
exit 1;
}

while getopts i:o:n: opt
do
case ${opt} in
i) INDIR_DIR=${OPTARG};;
o) OUTDIR_DIR=${OPTARG};;
n) NUMREADS=${OPTARG};;
*) usage;;
esac
done

NUMREADS=$(($NUMREADS * 4))

if [ "${INDIR_DIR}" = "" ]; then usage; fi
if [ "${OUTDIR_DIR}" = "" ]; then usage; fi
if [ "${NUMREADS}" = "" ]; then usage; fi


for file in $INDIR_DIR/*
	do
		if [ -f $file ]; then
			if [[ $file =~ .fastq.gz$ ]]; then
				filename=$(basename $file)
				 filenamewitoutext=${filename%%.*}
				echo $filenamewitoutext;

				if [ -f $OUTDIR_DIR/$filenamewitoutext.fastq.gz ]; then
					echo "$file already processed"
				else
					zcat $file | head -n $NUMREADS | gzip > $OUTDIR_DIR/$filenamewitoutext.fastq.gz
				fi
			fi
		fi
	done







