///references: it is modified because it was copied from https://stackoverflow.com/questions/4026648/how-to-implement-low-pass-filter-using-java

//also this might be tried https://baumdevblog.blogspot.com/2010/11/butterworth-lowpass-filter-coefficients.html
//https://code-examples.net/en/q/3d7118
public double[] fftLowpass(double[] timewindow, double lowPassfreq, double frequency){
    //timewindow: input data.
    //lowPassfreq: The cutoff frequency 
    //frequency: fs

    //The apache Fft (Fast Fourier Transform) accepts arrays that are powers of 2.
    int minPof2 = 1;
    while(minPof2 < timewindow.length)
        minPof2 = 2 * minPof2;

    //empty array with zeros
    double[] empty = new double[minPof2];
    for(int i = 0; i < timewindow.length; i++)
        empty[i] = timewindow[i];


    FastFourierTransformer fft = new FastFourierTransformer(DftNormalization.STANDARD);
    Complex[] fTransform = fft.transform(empty, TransformType.FORWARD);

    //frequency domain array
    double[] frequencyDomain = new double[fTransform.length];
    for(int i = 0; i < frequencyDomain.length; i++)
        frequencyDomain[i] = frequency * i / (double)fTransform.length;

    //build convolution rectangle, 2s are kept and 0s do not pass the filter
    double[] lowfreqs = new double[frequencyDomain.length];
    lowfreqs[0] = 1; 
    for(int i = 1; i < frequencyDomain.length; i++){
        if(frequencyDomain[i] < lowPassfreq)
            lowfreqs[i] = 2;
        else
            lowfreqs[i] = 0;
    }

    //filtering
    for(int i = 0; i < fTransform.length; i++)
        fTransform[i] = fTransform[i].multiply((double)lowfreqs[i]);

    //inversing to the time domain
    Complex[] inverseFourier = fft.transform(fTransform, TransformType.INVERSE);

    //getting the filtered results
    double[] result = new double[timewindow.length];
    for(int i = 0; i< result.length; i++){
        filtered[i] = inverseFourier[i].getReal();
    }

    return filtered;
}