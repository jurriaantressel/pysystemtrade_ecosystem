FROM python:3.11-slim

ARG USER_ID=99
ARG GROUP_ID=100
ARG USER_NAME="nobody"
ARG BC_UTILS_REPO_TARGET_DIR
ARG BC_UTILS_REPO_SOURCE_DIR

# Set environment variable for the time zone
ENV TZ=America/Chicago \
    USER_ID=$USER_ID \
    GROUP_ID=$GROUP_ID \
    BC_UTILS_REPO_TARGET_DIR=$BC_UTILS_REPO_TARGET_DIR

# Copy project and cronfile
COPY $BC_UTILS_REPO_SOURCE_DIR $BC_UTILS_REPO_TARGET_DIR/
COPY $BC_UTILS_REPO_SOURCE_DIR/cronfile /etc/cron.d/mycron

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils cron iputils-ping && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -u $USER_ID -g $GROUP_ID $USER_NAME

# Set timezone, permissions, and apply cron jobs
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    chmod 0644 /etc/cron.d/mycron && \
    username=$(getent passwd $USER_ID | cut -d: -f1) && \
    crontab -u $username /etc/cron.d/mycron && \
    chmod u+s /usr/sbin/cron

# Set work directory
WORKDIR $BC_UTILS_REPO_TARGET_DIR

# Set permissions for scripts
RUN chmod +x entrypoint.sh ping.sh run_bc_utils.sh && \
    chown -R $USER_ID:$GROUP_ID . && \
    chmod u+s .

# Install Python packages within a virtual environment
RUN python -m venv bcutils_env && \
    . bcutils_env/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install yfinance

# Ensure cron service starts and keeps running in the foreground
CMD ["cron", "-f"]

# Switch to the nobody user
USER $USER_ID

ENTRYPOINT ["./entrypoint.sh"]