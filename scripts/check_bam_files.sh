#!/bin/bash -e
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

for var in "$@"
do

	filename=$(basename $var)
	filenamewitoutext=${filename%%.*}
#echo "$var $filenamewitoutext";
	samtools view -H $var | grep "^@RG" | while read -r line;
	do
		name=$(echo "$line" | awk '{x = split($0,a,"SM:");print a[2] }')
		if [[ $filenamewitoutext != $name  ]]; then
			echo "Wrong sample in SAM file: $var $filenamewitoutext $name" 1>&2 ;
			exit 1;
		fi
	done
done

exit 0 ;

