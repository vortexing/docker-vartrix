FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
    wget
RUN wget https://github.com/10XGenomics/vartrix/releases/download/v1.1.16/vartrix_linux 
RUN mv vartrix_linux vartrix
RUN chmod a+x vartrix

