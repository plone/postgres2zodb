# Base image with PostgreSQL 16
FROM postgres:16

# Install Python and dependencies
RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/90insecure \
 && echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/90insecure \
 && apt-get update \
 && apt-get install -y python3 python3-pip python3-venv \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

 # Create virtualenv and install ZODB
RUN python3 -m venv /opt/zodbenv && \
    /opt/zodbenv/bin/pip install --no-cache-dir relstorage==4.1.1 psycopg2-binary==2.9.10

# Create working directories
#WORKDIR /data
#VOLUME /var/lib/postgresql/data
VOLUME /data

# Copy conversion script into init directory so it runs after DB init
COPY convert.sh /docker-entrypoint-initdb.d/convert.sh
COPY relstorage.cfg /opt/zodbenv

RUN chmod +x /docker-entrypoint-initdb.d/convert.sh

ENV PATH="/opt/zodbenv/bin:$PATH"
