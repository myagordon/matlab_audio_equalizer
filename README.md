The goal is to implement a 5-band audio equalizer in MATLAB that lets the user modify the gain of various frequency bands in an audio signal. This is a personal project meant to help teach me a bit more about FIR and IIR digital filters and matlab. 

Designed simple FIR low-pass, band-pass, and high-pass filters using windowed-sinc (fir1), applied per-band gains in dB, and reconstructed the equalized signal by summing the bands. Visualized time and frequency domain behavior and filter responses using FFT and freqz.

**This project was inspired by [Divyansh Pandey](https://github.com/divyansh10100/equalizer-realization-using-matlab) and I also found the MathWorks documentation on IIR and FIR filter to be helpful.  
