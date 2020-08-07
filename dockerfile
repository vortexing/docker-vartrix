FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
    wget
RUN wget https://github.com/10XGenomics/vartrix/releases/download/v1.1.16/vartrix_linux 
RUN mkdir vartrix_dir  && mv vartrix_linux ./vartrix_dir/vartrix && chmod a+x vartrix_dir/vartrix
ENV PATH=$PATH:/vartrix_dir