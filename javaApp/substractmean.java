private static double[] substractMean(double[] datawindow){
	
	double[] substracted = new double[datawindow.length];
	double mean =mean(datawindow);

	for (int i=0;i<datawindow.length;i++){
		substracted[i] = datawindow[i] - mean;
	}
	return substracted;
}


// reference https://searchcode.com/codesearch/view/78094523/