FROM node:22-alpine

# Install mcp-proxy globally
RUN npm install -g mcp-proxy

# Set environment variables
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package files for better caching
COPY package*.json ./
COPY yarn.loc[k] ./

# Install ALL dependencies (including devDependencies for build)
RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then \
        npm ci; \
    else \
        npm install; \
    fi

# Copy application code
COPY . .

# Build if build script exists
RUN if grep -q '"build"' package.json; then \
        if [ -f yarn.lock ]; then yarn build; else npm run build; fi; \
    fi

# Clean up dev dependencies and cache AFTER build
RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile --production=true; \
    else \
        npm prune --production; \
    fi && \
    npm cache clean --force && \
    rm -rf /tmp/* /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S appuser && adduser -S appuser -G appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
ENTRYPOINT ["mcp-proxy"]
