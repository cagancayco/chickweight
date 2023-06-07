# Install R version 4.1.2
FROM r-base:4.1.2

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    libnlopt-dev \
    libudunits2-dev \
    libgeos-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgdal-dev \
    git             
    
# Install Shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt) && \
    wget "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb
    
##### Install R packages that are required ######
## CRAN packages
RUN R -e "install.packages(c('shiny','shinydashboard','dplyr','ggplot2','fresh'))"


# Copy configuration files into the Docker image
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN rm -rf /srv/shiny-server/*

# Get the app code
RUN git clone https://github.com/uvarc/chickweight.git
RUN cp -r chickweight/* /srv/shiny-server/
RUN rm -rf chickweight

# Make the ShinyApp available at port 80
ENV R_HOME=/usr/lib/R
ENV PATH=/usr/lib/R:/usr/lib/R/bin:$PATH
EXPOSE 80
WORKDIR /srv/shiny-server
RUN chown shiny.shiny /usr/bin/shiny-server.sh && chmod 755 /usr/bin/shiny-server.sh

# Run the server setup script
CMD ["/usr/bin/shiny-server.sh"]