# Use official Node.js image
FROM node:20

# Set working directory
WORKDIR /usr/src/app

# Copy package.json & install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files
COPY . .

# Run the Node.js script
CMD ["node", "src/weightSensor.js"]
