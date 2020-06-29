


check_output = {
    doc "Checkng output dir exists "	
	outdir = new File("/tmp");
    if (outdir.exists())
	{
		// check if we have write access
		if(outdir.canWrite())
		{
  			// write access, so move forward
		}
		else
		{
  			// no write access
			fail "Can't write to /OUTPUT directory. Please check permissions and try again"
		}
		// exists, so move forward	
    }
    else
	{
     	fail "Can't find /OUTPUT directory.  Please check it is mapped correctly and try again"
	}

}

check_input = {
	doc "Check input"
	indir = new File("/tmp");
	if (indir.exists())
	{
		if (input.input.size==0)
		{
			// no input files specified, so look for anything matching our default pattern
			input = glob("/tmp/*.unp")
		}
			// exists, so move forward      
	}
	else
	{
		fail "Can't find /INPUT directory.  Please check it is mapped correctly and try again"
	}

	forward(input)
}

run_fastqc = {
	System.out.println(input)
	if (FILTERMAPQ==1)
	{
		System.out.println("here")
	}
	forward(input)
}


Bpipe.run {check_input + check_output + [run_fastqc] + "*.unp" * [run_fastqc]}
