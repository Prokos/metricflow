# Start with a base Python image
FROM python:3.9-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        default-libmysqlclient-dev \
        libpq-dev \
        curl \
        gnupg \
		git \
    && rm -rf /var/lib/apt/lists/*

# Install PostgreSQL client (for PostgreSQL support)
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install make (assuming it's not already included in Python image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends make && \
    rm -rf /var/lib/apt/lists/*

# Set up the working directory
WORKDIR /app

# Copy pyproject.yaml and install Hatch
COPY pyproject.yaml .

# Copy MetricFlow repo from local directory
COPY . .

RUN make install-hatch

# Create a script to echo a message
RUN echo '#!/bin/bash\n\
echo " "\n\
echo "Metricflow environment started!"\n\
echo " "\n\
echo "Run the whole test suite:     $(tput bold)make test$(tput sgr0)"\n\
echo "Run tests within a subdir:    $(tput bold)hatch run dev-env:pytest tests_metricflow/plan_conversion$(tput sgr0)"\n\
echo "Run tests based on substring: $(tput bold)hatch run dev-env:pytest -k "query" tests_metricflow$(tput sgr0)"\n\

echo " "\n\
exec "$@"' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Set entry point to the script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set up default command
CMD ["bash"]
