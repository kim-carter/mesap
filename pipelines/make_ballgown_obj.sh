
#!/bin/bash

echo "library(ballgown)" > ballgownR_glue.R
echo -ne "sample_directories <- c(" >> ballgownR_glue.R
counter=1
for line in $(find  . -name "e2t.ctab"); do 
	a="$(echo $line   | rev | cut -d"/" -f2,3 | rev)"
	if [ $counter = 1 ]; then
		echo -ne "'$a'" >> ballgownR_glue.R
	else
		echo -ne ",'$a'" >> ballgownR_glue.R
	fi
	counter=$(($counter + 1));
done
echo ")" >> ballgownR_glue.R
echo "bg <- ballgown(samples = sample_directories)" >> ballgownR_glue.R

echo "save(bg, file = 'bg.rda')" >> ballgownR_glue.R

Rscript  ballgownR_glue.R

