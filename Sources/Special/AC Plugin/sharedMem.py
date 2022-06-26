import mmap
import os
import struct
import functools
import ctypes
from ctypes import c_float, c_char, c_int32

class vec3(ctypes.Structure):
    _pack_ = 4
    _fields_ = [
        ('x', c_float),
        ('y', c_float),
        ('z', c_float),
        ]

class acsVehicleInfo(ctypes.Structure):
    _pack_ = 4
    _fields_ = [
        ('carId', c_int32),
        ('driverName', c_char * 64),
        ('carModel', c_char * 64),
        ('speedMS', c_float),
        ('bestLapMS', c_int32),
        ('lapCount', c_int32),
        ('currentLapInvalid', c_int32),
        ('currentLapTimeMS', c_int32),
        ('lastLapTimeMS', c_int32),
        ('worldPosition', vec3),
        ('isCarInPitline', c_int32),
        ('isCarInPit', c_int32  ),
        ('carLeaderboardPosition', c_int32),
        ('carRealTimeLeaderboardPosition', c_int32),
        ('splinePosition', c_float),
        ('isConnected', c_int32),
        ('suspensionDamage', c_float * 4),
        ('engineLifeLeft', c_float),
        ('tyreInflation', c_float * 4),
    ]
      
class SPageFileSC(ctypes.Structure):
    _pack_ = 4
    _fields_ = [
        ('numVehicles', c_int32),
        ('focusVehicle', c_int32),
        ('serverName', c_char * 512),
        ('vehicleInfo', acsVehicleInfo * 64),
        ('acInstallPath', c_char * 512),
        ('isInternalMemoryModuleLoaded', c_int32),
        ('pluginVersion', c_char * 32)		
    ]

class SCShared:
    def __init__(self):
        self._acpmf_sc = mmap.mmap(0, ctypes.sizeof(SPageFileSC),"acpmf_sc")
        self.sc = SPageFileSC.from_buffer(self._acpmf_sc)
              
    def close(self):
        self._acpmf_sc.close()

    def __del__(self):
        self.close()
            
    def getsharedmem(self):
        return self.sc
        
