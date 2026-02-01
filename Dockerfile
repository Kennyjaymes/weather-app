# Stage 1 — Build static assets (if app uses build step)
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy all source
COPY . .

# Build the project (for e.g., React or other JS build)
RUN npm run build

# Stage 2 — Serve app with nginx (no root inside container)
FROM nginx:stable-alpine

# Create an app user (non-root)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from previous stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Set proper permissions
RUN chown -R appuser:appgroup /usr/share/nginx/html

# Switch to non-root user
USER appuser

# Expose default HTTP port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
