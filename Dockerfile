FROM rocker/r-base:4.2.1

# complete Linux packages with dockerfiler
RUN apt-get update && apt-get install -y --no-install-recommends \
libicu-dev \
libpng-dev \
make \
pandoc \
zlib1g-dev \
&& rm -rf /var/lib/apt/lists/*

RUN addgroup --system app \
&& adduser --system --ingroup app app

WORKDIR /home/shiny-app

COPY . .

RUN chown app:app -R /home/shiny-app

USER app

# Initialize new renv project
RUN R -e "renv::init()"

# Restore project dependencies
RUN R -e "renv::restore()"

# Expose port
EXPOSE 3838

# Run command to start Shiny in the container
CMD ["R", "-e", "shiny::runApp('/home/shiny-app', port = 3838, host = '0.0.0.0')"]