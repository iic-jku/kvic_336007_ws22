# -*- coding: utf-8 -*-
"""
Created on Thu Oct 13 08:45:39 2022

@author: Ratschenberger

Class to handle the simulation results for the audiodac_python_tb

"""

import os
import numpy as np

class AudioDACSimResults:
        def __init__(self, DIR):
            with open(DIR,'r') as f:
                lines = f.readlines()
 
            data = "" 
            for line in lines:
                if not (line.startswith("//") or line.startswith("x")):
                    data = data + line
                        
            data = np.fromstring(data,dtype=int,sep="\n")
            
            self.result = data     
                   
        def getSIM_Result(self):
            return self.result
        
            
        