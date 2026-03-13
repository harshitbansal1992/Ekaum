#!/bin/bash

# BSLND Backend - Multi-Mode Startup Script
# ==========================================
# Easily run the backend in different modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the mode from command line argument
MODE=${1:-development}

# Validate mode
case $MODE in
  development|dev)
    MODE="development"
    EMOJI="🚀"
    ;;
  test)
    MODE="test"
    EMOJI="🧪"
    ;;
  production|prod)
    MODE="production"
    EMOJI="⚡"
    ;;
  *)
    echo -e "${RED}❌ Invalid mode: $MODE${NC}"
    echo -e "${BLUE}Usage: ./start.sh [development|test|production]${NC}"
    exit 1
    ;;
esac

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}⚠️  node_modules not found. Running npm install...${NC}"
  npm install
fi

# Set environment variable
export NODE_ENV=$MODE

echo -e "${GREEN}${EMOJI} Starting BSLND Backend in ${MODE} mode...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Run appropriate command
if [ "$MODE" = "production" ]; then
  echo -e "${YELLOW}Running: npm start${NC}"
  npm start
elif [ "$MODE" = "test" ]; then
  if [ "$2" = "watch" ]; then
    echo -e "${YELLOW}Running: npm run test:watch${NC}"
    npm run test:watch
  else
    echo -e "${YELLOW}Running: npm run test${NC}"
    npm run test
  fi
else
  echo -e "${YELLOW}Running: npm run dev${NC}"
  npm run dev
fi

