private static double[] energy(double[] datawindow){
	double energy = 0.0;
	double mean =mean(datawindow);
	for (int i = 0; i < datawindow.length; i++) {           
            energy=energy+(datawindow)^2;        
        }      
    energy /= (double)datawindow.length
    
    return energy;
}
