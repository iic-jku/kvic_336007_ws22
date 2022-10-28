# -*- coding: utf-8 -*-
"""
Created on Thu Oct 13 08:45:39 2022

@author: Ratschenberger

Class to handle the simulation settings for the audiodac_python_tb

"""

import os

class AudioDACSimVals:
        def __init__(self, SIM_MODE, SIM_OSR, SIM_VOLUME, SIM_DATA):
            self.SIM_MODE = SIM_MODE
            self.SIM_OSR = SIM_OSR
            self.SIM_VOLUME = SIM_VOLUME
            self.SIM_DATA = SIM_DATA
            
        def __defStr(self, param, val):
            return "`define " + str(param) + " " + str(val)
        
        
        def writeSimParam(self, directory=""):
            SimParam = list()
            
            SimParam.append(self.__defStr("SIM_MODE", self.SIM_MODE))
            SimParam.append(self.__defStr("SIM_OSR",  self.SIM_OSR))
            SimParam.append(self.__defStr("SIM_VOLUME",  self.SIM_VOLUME))
            SimParam.append(self.__defStr("SIM_DATA_SAMPLES", len(self.SIM_DATA)))
            
            if os.path.exists(directory + "audiodac_simParam.v"):
                os.remove(directory + "audiodac_simParam.v")
                
            with open(directory + "audiodac_simParam.v",'w') as f:
                for line in SimParam:
                    f.write(line + "\n")
                    
        def writeSimData(self, directory=""):
            if os.path.exists(directory+"audiodac_test_data.txt"):
                os.remove(directory+"audiodac_test_data.txt")
             
            with open(directory + "audiodac_test_data.txt",'w') as f:
                for d in self.SIM_DATA:
                    f.write(format(int(d)&0xffff,'04x') + "\n")
                
        def genSimFiles(self):
            self.writeSimData()
            self.writeSimParam("../dig/rtl/")
            
        def setSIM_MODE(self, SIM_MODE):
            self.SIM_MODE = SIM_MODE
        
        def setSIM_OSR(self, SIM_OSR):
            self.SIM_OSR = SIM_OSR
            
        def setSIM_VOLUME(self, SIM_VOLUME):
            self.SIM_VOLUME = SIM_VOLUME
            
        def setSIM_DATA(self, SIM_DATA):
            self.SIM_DATA = SIM_DATA
            
        def getSIM_MODE(self):
            return self.SIM_MODE
        
        def getSIM_OSR(self):
            return self.SIM_OSR
        
        def getSIM_VOLUME(self):
            return self.SIM_VOLUME
        
        def getSIM_DATA(self):
            return self.SIM_DATA
        
            
        