# 1. Use an official Node.js v20 image based on Debian Bookworm Slim
FROM node:20-bookworm-slim

# 2. Install essential system dependencies for building native modules (like sharp)
#    Includes git, CA certificates, and libvips (needed by sharp)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    python3 \
    libvips-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Set the working directory inside the container
WORKDIR /usr/src/app

# 4. Copy package definition file (only package.json needed initially)
COPY package.json ./

# 5. Install ALL dependencies using Yarn (force --production=false)
#    Allow install scripts to run (for sharp), increase network timeout
#    Also install ts-node globally just in case
RUN yarn install --frozen-lockfile --network-timeout 1000000 --production=false && yarn global add ts-node

# 6. Copy the rest of your application code into the container
COPY . .

# 7. ---> SKIP THE BUILD STEP (No RUN ... tsc line) <---

# 8. Expose the port the application will run on (matching your PORT env variable)
EXPOSE 5000

# 9. Define the command to run the app using ts-node directly (Try npx again first)
CMD [ "npx", "ts-node", "src/index.ts" ]
# Fallback: CMD [ "node", "-r", "ts-node/register", "src/index.ts" ]
# Another Fallback: CMD [ "ts-node", "src/index.ts" ]
