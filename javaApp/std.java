
private static double[] std(double[] datawindow){
	double standardDeviation = 0.0;
	double mean =mean(datawindow);
	for (int i = 0; i < datawindow.length; i++) {           
            standardDeviation = standardDeviation + Math.pow((arr[i] - mean), 2);           
        }      
    sq = standardDeviation / datawindow.length;
    res = Math.sqrt(sq);
    return res;
}

https://www.geeksforgeeks.org/java-program-to-calculate-standard-deviation/