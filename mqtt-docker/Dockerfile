# Use official Mosquitto image as base
FROM eclipse-mosquitto:2.0.22

# Copy our custom config
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Expose port
EXPOSE 1883

# Start Mosquitto with our config
CMD ["mosquitto", "-c", "/mosquitto/config/mosquitto.conf", "-v"]
