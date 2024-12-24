The goal is to implement an audio equalizer in MATLAB that lets the user modify the gain of various frequency bands in an audio signal. This is a personal project meant to help teach me a bit more about FIR and IIR digital filters and matlab. 

The program will prompt the user to provide an audio file in .wav format, and will subsequently ask the user to select a filter and apply it to the audio data. Will also allow user to specify gain for each frequency band, then returns and plots the final output. I'm considering providing an option for users to define custom frequency bands beyond predefined ranges, or supporting overlapping bands for smoother transitions between frequency ranges.

**This project was inspired by [Divyansh Pandey] (https://github.com/divyansh10100/equalizer-realization-using-matlab) and I also found the MathWorks documentation on IIR and FIR filter to be helpful.  
