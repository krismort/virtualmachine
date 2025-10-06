# Use a recent Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive frontend to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages in stages to avoid timeout issues
RUN apt-get update && apt-get install -y \
    openssh-server \
    stunnel4 \
    supervisor \
    pwgen \
    openssl \
    xvfb \
    wget \
    curl \
    expect \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install desktop environment and VNC packages
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    tightvncserver \
    firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user
RUN useradd -m -s /bin/bash appuser

# Configure SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Create directories for stunnel
RUN mkdir -p /var/run/stunnel4 /var/log/stunnel4 /etc/stunnel

# Generate self-signed certificate for stunnel
RUN openssl req -x509 -newkey rsa:2048 -keyout /tmp/key.pem -out /tmp/cert.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
RUN cat /tmp/key.pem /tmp/cert.pem > /etc/ssl/certs/stunnel.pem
RUN chmod 600 /etc/ssl/certs/stunnel.pem
RUN rm /tmp/key.pem /tmp/cert.pem

# Copy configuration files
COPY stunnel.conf /etc/stunnel/stunnel.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Create VNC directory
RUN mkdir -p /home/appuser/.vnc
RUN chown -R appuser:appuser /home/appuser

# Set up X11 forwarding
RUN mkdir -p /tmp/.X11-unix
RUN chmod 1777 /tmp/.X11-unix

# Expose ports
EXPOSE 22 443 5900

# Define a volume for persistent data
VOLUME /data

# Set the entrypoint
CMD ["/startup.sh"]
