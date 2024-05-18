# Builder stage to clone repository
FROM python:3.10.13 as builder
ARG BC_UTILS_REPO_NAME
ARG BC_UTILS_REPO_OWNER
ARG BC_UTILS_REPO_ACCESS_TOKEN
ARG BC_UTILS_REPO_DIR
ARG CONFIG_REPO_NAME=${CONFIG_REPO_NAME}
ARG CONFIG_REPO_OWNER=${CONFIG_REPO_OWNER}
ARG CONFIG_REPO_ACCESS_TOKEN=${CONFIG_REPO_ACCESS_TOKEN}
ARG CONFIG_REPO_DIR

# Clone the necessary repository
RUN git clone -b main https://$BC_UTILS_REPO_ACCESS_TOKEN:@github.com/$BC_UTILS_REPO_OWNER/$BC_UTILS_REPO_NAME.git $BC_UTILS_REPO_DIR && \
    git clone -b master https://$CONFIG_REPO_ACCESS_TOKEN:@github.com/$CONFIG_REPO_OWNER/$CONFIG_REPO_NAME.git $CONFIG_REPO_DIR


# Final stage
# Use an official Python runtime as a parent image
FROM python:3.11-slim as final_stage
ARG USER_ID=99
ARG GROUP_ID=100
ARG ENVIRONMENT
ARG BC_UTILS_REPO_NAME
ARG BC_UTILS_REPO_DIR
ARG CONFIG_REPO_DIR

# Set environment variable for the time zone
ENV TZ=America/Chicago \
    USER_ID=$USER_ID \
    GROUP_ID=$GROUP_ID \
    BC_UTILS_REPO_DIR=$BC_UTILS_REPO_DIR

# Copy project and cronfile from builder stage
COPY --from=builder $BC_UTILS_REPO_DIR $BC_UTILS_REPO_DIR
COPY --from=builder $BC_UTILS_REPO_DIR/cronfile /etc/cron.d/mycron
COPY --from=builder $CONFIG_REPO_DIR/$BC_UTILS_REPO_NAME/$ENVIRONMENT $BC_UTILS_REPO_DIR/configs

# Install system dependencies
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    username=$(getent passwd $USER_ID | cut -d: -f1) && \
    chmod 0644 /etc/cron.d/mycron && \
    crontab -u $username /etc/cron.d/mycron && \
    chmod u+s /usr/sbin/cron

# Set work directory
WORKDIR $BC_UTILS_REPO_DIR

# Set permissions for scripts first
RUN chmod +x entrypoint.sh ping.sh run_bc_utils.sh && \
    chown -R $USER_ID:$GROUP_ID . && \
    chmod u+s .

# Then install Python packages within a virtual environment
RUN python -m venv bcutils_env && \
    . bcutils_env/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install yfinance


# Switch to the nobody user
USER $USER_ID

ENTRYPOINT ["./entrypoint.sh"]