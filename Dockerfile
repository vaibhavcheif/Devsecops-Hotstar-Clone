# Use Node 18 instead of latest
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy project files
COPY . .

# Expose React port
EXPOSE 3000

# Start React app
CMD ["npm", "start"]
