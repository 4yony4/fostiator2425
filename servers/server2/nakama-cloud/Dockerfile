# Use Nakama's official image
FROM heroiclabs/nakama:latest

# Set Nakama server configurations via environment variables
ENV NAKAMA_DATA_DIR /nakama/data
ENV NAKAMA_DATABASE_ADDRESS postgresql://postgres:yourpassword@35.239.181.155:5432/nakama

# Expose the Nakama server port
EXPOSE 7350

# Start the Nakama server
CMD ["nakama", "–config", "nakama.yml"]