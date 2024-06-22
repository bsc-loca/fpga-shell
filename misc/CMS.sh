#!/bin/bash


dma-ctl dev list

# Variable $1 is the address of the CMS and variable $2 is the bar region (can be seen with: dma-ctl qdma08000 reg dump)
ADDR=$1
PCIE_SLOT=`lspci -m -d 10ee:| cut -d " " -f 1 | cut -d ":" -f 1`
#We are filtering the output of lscpi (list of PCIe in the system) with the vendor ID (Xilinx PCIe) 10ee, and the flag -d
#this number will differ depending on the server, so it can't be hardcoded. 
#result of this will be a 2 digit number z.B. 08

QDMA_PCI="qdma${PCIE_SLOT}000" #Constructs the PCI device identifier

echo -n "axi-lite bar: "
dma-ctl $QDMA_PCI reg read bar 0 0x10C | grep "0x10c" | cut -d '=' -f2 | cut -d 'x' -f2 | cut -d '.' -f1 
echo "axi-lite bar -> 2 equals 1, 4 equals 2 (aka divide bt two)"

#dma-ctl qdma01000 q start idx 4 dir h2c

#Writes a value to the second BAR (base address register) of the QDMA PCI device identified by QDMA_PCI. Idk why it is this concrete value, but it seems that it is needed to properly configure the QDMA device for the subsequent DMA read operation.

#dma-ctl $QDMA_PCI reg write bar $2 0x0 0x3 >> /dev/null 
dma-ctl $QDMA_PCI reg write bar 0 0x0 0x3 >> /dev/null 

sleep 0.1

#Reads data from the QDMA device into a file called "readback"
dma-from-device -d /dev/$QDMA_PCI-MM-1 -s 4 -a $ADDR -f readback >> /dev/null
truncate -s %4 readback
objcopy -I binary -O binary --reverse-bytes=4 readback
cat readback | xxd  -c 4 | awk '{print $2 $3}' > content
cat content

# Repeat
echo "<1/0>"

rm readback

dma-from-device -d /dev/$QDMA_PCI-MM-0 -s 4 -a $ADDR -f readback >> /dev/null
truncate -s %4 readback
objcopy -I binary -O binary --reverse-bytes=4 readback
cat readback | xxd  -c 4 | awk '{print $2 $3}' > content
cat content

dma-ctl $QDMA_PCI stat

rm readback

#Reads data from the QDMA device into a file called "readback"
dma-from-device -d /dev/$QDMA_PCI-MM-1 -s 4 -a $ADDR -f readback >> /dev/null
truncate -s %4 readback
cat readback | xxd  -c 4 | awk '{print $2 $3}' > content
cat content

#Write to device
#dma-to-device -d /dev/$QDMA_PCI-MM-0 -s 64 -a $ADDR <filetowrite>
rm readback

dma-ctl $QDMA_PCI reg dump
echo "------------------------------------------------------------"
lspci -Dd 10ee: -vvv