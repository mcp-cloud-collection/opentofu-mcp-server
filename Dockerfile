FROM node:22-alpine

# Install mcp-proxy globally
RUN npm install -g mcp-proxy

# Set working directory
WORKDIR /app

# Copy package files for better caching
COPY package*.json ./
COPY yarn.loc[k] ./

# Install only production dependencies
RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile --production; \
    elif [ -f package-lock.json ]; then \
        npm ci --omit=dev; \
    else \
        npm install --production; \
    fi

# Copy application code
COPY . .

# Clean up cache
RUN npm cache clean --force && \
    rm -rf /tmp/* /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S appuser && adduser -S appuser -G appuser
RUN chown -R appuser:appuser /app
USER appuser

# Set production environment
ENV NODE_ENV=production

EXPOSE 8080
ENTRYPOINT ["mcp-proxy"]
