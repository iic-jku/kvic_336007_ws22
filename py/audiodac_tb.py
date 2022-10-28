"""
    AUDIODAC_TB
    
    (c) 2022 Jakob Ratschenberger
    Johannes Kepler University Linz, Institute for Integrated Circuits
    
    Python script to controll and perform the simulation of the AUDIODAC. 
    
    Implemented functionality:
        - Setting the AUDIODAC configurations (OSR, MODE, VOLUMNE)
        - Setting the AUDIODAC input data
            -- Four sets are available:
                + Filtered White Gaussian Noise
                + Sine with 10kHz
                + All zeros
                + Sound of an bell
        - Data visualisation
            -- Plotting the input data in time and frequency domain
            -- Plotting the output data in frequency domain
        - Generating .wav of the AUDIODAC output for the sound input
            -- Resamples the AUDIODAC output stream to 44100Hz

"""


import os
import numpy as np
import scipy.signal as signal
from scipy.io import wavfile
import matplotlib.pyplot as plt
import AudioDACSimVals as simvals
import AudioDACSimResults as simresults

fs = 44100  #Input sampling rate  
    
BW = 16     #Bitwidth

#Request the simulation parameters

#Set the Oversampling Rate (OSR)
OSR = int(input("SIM_OSR: (32/64/128/256) "))
if OSR not in [32,64,128,256]:
    raise ValueError("OSR {} not supported!".format(OSR))
 
#Convert the entered OSR in the desired range of the AUDIODAC
SIM_OSR = 0
if OSR == 64:
    SIM_OSR = 1
elif OSR == 128:
    SIM_OSR = 2 
elif OSR == 256:
    SIM_OSR = 3

#Set the mode of the AUDIODAC
    #Mode 0 => 1st order DSMOD
    #Mode 1 => 2nd order DSMOD
SIM_MODE = int(input("SIM_MODE: (0/1) "))
if SIM_MODE not in [0,1]:
    raise ValueError("SIM_MODE {} not supported!".format(SIM_MODE))

#Set the volumne
SIM_VOLUME = int(input("SIM_VOLUME: (0 = 0dB, 1 = -6dB , 15 = off) "))
if SIM_VOLUME not in [_ for _ in range(16)]:
    raise ValueError("SIM_VOLUME {} not supported!".format(SIM_VOLUME))


#Set the desired test set
TestSet = int(input("""Which testset?
         (1) Filtered WGN 
         (2) Sine (10kHz) 
         (3) Zeros
         (4) Sound
    Your selection: """))
                     
if TestSet not in [1,2,3, 4]:
    raise ValueError("Testset not supported!")

#If the test set isn't the sound, ask for the number of simulated samples
if TestSet not in [4]:  
    nSamples = int(input("Number of samples ([44,441000]): "))
    #Set a lower and upper bound
        #Lower bound to prevent to less output samples
        #Upper bound to prevent to long simulation 
    if nSamples < 44 or nSamples > 10*44100: 
        raise ValueError("Number of samples not supported!")

#Set the input data
if TestSet == 1:
    test_data = np.random.randint(-2**(BW-1), 2**(BW-1)-1,nSamples)
    lowpass = signal.firwin(100, fs/4, fs=fs)
    test_data = signal.lfilter(lowpass, 1, test_data)
elif TestSet == 2:
    test_data = 0.5*2**(BW-1)*np.sin(2*np.pi*10000/fs * np.arange(nSamples))
elif TestSet == 3:
    test_data = 0*np.arange(nSamples)
elif TestSet == 4:
    sound_sample_rate, test_data = wavfile.read("Bell.wav")
    nSamples = len(test_data)
  

#Calc. the spectrum of the test data
freq_test_data = np.fft.fft(test_data, norm="forward")
f = np.fft.fftfreq(freq_test_data.size, 1/fs)

#Plot the test data in time domain
fig, ax = plt.subplots()
fig.suptitle(r'Test data')
ax.plot(test_data, 'b')
ax.set_xlabel(r'n')
ax.set_ylabel(r'$x_{Test}[n]$')
ax.grid(True)
plt.draw()

#Plot the spectrum of the test data
fig, ax = plt.subplots()
fig.suptitle(r'Spectrum of the test data')
x = np.fft.fftshift(f)
y = np.abs(np.fft.fftshift(freq_test_data))
ax.plot(x,y, 'b')
ax.set_xlabel(r'$f\,/\,Hz$')
ax.set_ylabel(r'$\mid \mathrm{fft}\left(x_{Test}[n]\right) \mid$ ')
ax.grid(True)
plt.draw()

#Setup the simulation values
mySimVals = simvals.AudioDACSimVals(SIM_MODE, SIM_OSR, SIM_VOLUME, test_data)

#Generate the necessary files for the sim
mySimVals.genSimFiles()

#Run the verilog simulation  
os.system("iverilog -g 2005 -o AUDIODAC_PY_TB -c file_list.txt")
os.system("vvp AUDIODAC_PY_TB")

#Set the file name of the simulation result
mySimResults = simresults.AudioDACSimResults("verilog_bin_out.txt")

#Read the simulation result
data = mySimResults.getSIM_Result()

data = (data)*2-1 #Merge the poitive and negative AUDIODAC output

data = data*2**(BW-1) #Scale the data to input range

#Calc. the spectrum of the AUDIODAC output stream
freq_data = np.fft.fft(data, norm="forward")
f = np.fft.fftfreq(freq_data.size,d=1/(fs*OSR))

#Plot the spectrum of the output data
fig, ax = plt.subplots()
fig.suptitle(r'Spectrum of the output data')
x = np.fft.fftshift(f)
y = np.abs(np.fft.fftshift(freq_data))
ax.plot(x,y, 'b')
ax.set_xlabel(r'$f\,/\,Hz$')
ax.set_ylabel(r'$\mid \mathrm{fft}\left(x_{out}[n]\right) \mid$')
ax.grid(True)
plt.draw()

#Get the output spectrum in the range 0 to fs/2
indx_fs = round(len(freq_data)/(OSR*2))
freq_data2 = freq_data[0:indx_fs-1]
f = f[0:indx_fs-1]

#Plot the output spectrum in the range 0 to fs/2
fig, ax = plt.subplots()
fig.suptitle(r'Zoomed spectrum of the output data')
x = f
y = np.abs(freq_data2)
ax.plot(x,y,'b')
ax.set_xlabel(r'$f\,/\,Hz$')
ax.set_ylabel(r'$\mid \mathrm{fft}\left(x_{out}[n]\right) \mid$')
ax.grid(True)
plt.draw()


#If the test set was the sound file
if TestSet == 4:
    
    
    #Resample the AUDIODAC output stream to fs by using Fourier method
    nSamples = round(len(data)/OSR)
    data = signal.resample(data,int(nSamples))
    
    #Write the output to a .wav file
    wavfile.write("AudioDAC.wav",fs, data.astype(np.int16))
    
    #Plot the waveform 
    fig, ax = plt.subplots()
    fig.suptitle(r'Waveform of the output data')
    ax.plot(data)
    ax.grid(True)
    plt.draw()

#Show all figures at the end  
plt.show()