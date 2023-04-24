##### Install dependencies only when needed ######
FROM node:18-alpine AS builder

# Make /app as working directory
WORKDIR /app

# Enable PNPM
RUN corepack enable && corepack prepare pnpm@latest --activate

# Files required by pnpm install
COPY package.json pnpm-lock.yaml ./

## Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the source code to the /app directory
COPY . .

## Build the application
RUN pnpm build --output-path=dist --output-hashing=all

######  Use Node alpine image  ######
FROM node:18-alpine

# Make /app as working directory
WORKDIR /app

# Copy dist folder from build stage to nginx public folder
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/server.js /app/server.js
COPY --from=builder /app/node_modules /app/node_modules

# Start NgInx services
CMD node /app/server.js
