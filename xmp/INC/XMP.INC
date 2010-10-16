; Include file for XMP

extrn xmp_sngname:dword
extrn xmp_sngchann:byte
extrn xmp_snglen:byte
extrn xmp_snginst:byte

extrn xmp_digchann:byte

extrn xmp_devtype:byte
extrn xmp_devport:word
extrn xmp_devirq1:byte
extrn xmp_devirq2:byte
extrn xmp_devdma1:byte
extrn xmp_devdma2:byte
extrn xmp_devmem:dword
extrn xmp_devaddr:dword
extrn xmp_devchann:byte

extrn xmp_status:byte
extrn xmp_flag:byte


extrn _XMP_Detect:near
extrn _XMP_Init:near
extrn _XMP_Load:near
extrn _XMP_Play:near
extrn _XMP_Stop:near
extrn _XMP_Prog:near
extrn _XMP_End:near

