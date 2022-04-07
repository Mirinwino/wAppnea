private static double[] mean(double[] datawindow){
	
	double mean =0.0;
	for (int i=0;i<datawindow.length;i++){ 
		mean += datawindow[i];			
	}
	
	mean /= (double)datawindow.length;

	return mean;
}

// reference https://searchcode.com/codesearch/view/78094523/

