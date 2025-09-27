FROM eclipse-mosquitto:2.0.22

# Copy custom config
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Run Mosquitto with custom config
CMD ["mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]