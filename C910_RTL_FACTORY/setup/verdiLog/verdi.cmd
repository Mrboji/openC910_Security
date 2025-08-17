debImport "-full64"
wvConvertFile -o \
           "/home/yuhao/ProgramFiles/Research/RISC-V/XUANTIE/lab/openc910-main-fpga-aes/smart_run/verdi/test.fsdb.fsdb" \
           "/home/yuhao/ProgramFiles/Research/RISC-V/XUANTIE/lab/openc910-main-fpga-aes/smart_run/verdi/test.fsdb"
debLoadSimResult \
           /home/yuhao/ProgramFiles/Research/RISC-V/XUANTIE/lab/openc910-main-fpga-aes/smart_run/verdi/test.fsdb.fsdb
wvRestoreSignal -win $_nWave2 \
           "/home/yuhao/ProgramFiles/Research/RISC-V/XUANTIE/lab/openc910-main-fpga-aes/smart_run/verdi/signal.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 20488395635.256752 -snap {("G3" 10)}
debExit
