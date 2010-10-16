; XMP -> soundcard low level rotines data interchange

extrn s_num:byte
extrn s_start:dword
extrn s_size:dword
extrn s_loops:dword
extrn s_loopl:dword
extrn s_offset:dword
extrn s_freq:dword
extrn s_vol:word
extrn s_pan:word
extrn s_type:byte
extrn s_bpm:word
extrn s_speed:word

extrn xmp_devtype:byte
extrn xmp_devport:word
extrn xmp_devirq1:byte
extrn xmp_devirq2:byte
extrn xmp_devdma1:byte
extrn xmp_devdma2:byte
extrn xmp_devmem:dword
extrn xmp_devaddr:dword
extrn xmp_devchann:byte


extrn _XMP_Main:near
