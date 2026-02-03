#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Banner
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║          🤖  MOLTRON INSTALLER  🤖        ║"
echo "║                                           ║"
echo "║    Self-Evolving OpenClaw Skill           ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# GitHub repository details
GITHUB_USER="${GITHUB_USER:-adridder}"       # Can be overridden with env var
GITHUB_REPO="${GITHUB_REPO:-moltron}"        # Can be overridden with env var
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"       # Can be overridden with env var

# Determine the target directory
TARGET_DIR="$HOME/.openclaw/workspace/skills"

echo -e "${BLUE}📍 Target installation directory:${NC}"
echo -e "   ${MAGENTA}$TARGET_DIR${NC}"
echo ""

# Check if the target directory exists, if not create it
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Target directory does not exist. Creating...${NC}"
    mkdir -p "$TARGET_DIR"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully created directory!${NC}"
    else
        echo -e "${RED}❌ Failed to create directory. Please check permissions.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Target directory exists!${NC}"
fi

echo ""

# Check if running from local repo or need to download
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR="$SCRIPT_DIR/moltron"

if [ -d "$SOURCE_DIR" ]; then
    # Local installation (repo is cloned)
    echo -e "${BLUE}📦 Installing from local repository...${NC}"
    INSTALL_MODE="local"
else
    # Remote installation (download from GitHub)
    echo -e "${BLUE}🌐 Downloading from GitHub...${NC}"
    INSTALL_MODE="remote"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Download the repository archive
    ARCHIVE_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.tar.gz"
    
    echo -e "${BLUE}   Downloading from: ${MAGENTA}$ARCHIVE_URL${NC}"
    
    if command -v curl &> /dev/null; then
        curl -sL "$ARCHIVE_URL" -o "$TEMP_DIR/repo.tar.gz"
    elif command -v wget &> /dev/null; then
        wget -q "$ARCHIVE_URL" -O "$TEMP_DIR/repo.tar.gz"
    else
        echo -e "${RED}❌ Error: Neither curl nor wget found. Please install one of them.${NC}"
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to download repository!${NC}"
        echo -e "${YELLOW}   Please check your internet connection and repository URL.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Download complete!${NC}"
    echo ""
    
    # Extract the archive
    echo -e "${BLUE}📂 Extracting files...${NC}"
    tar -xzf "$TEMP_DIR/repo.tar.gz" -C "$TEMP_DIR"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to extract archive!${NC}"
        exit 1
    fi
    
    # Find the moltron folder in the extracted archive
    SOURCE_DIR=$(find "$TEMP_DIR" -type d -name "moltron" -not -path "*/\.*" | head -n 1)
    
    if [ -z "$SOURCE_DIR" ] || [ ! -d "$SOURCE_DIR" ]; then
        echo -e "${RED}❌ Error: 'moltron' folder not found in the downloaded repository!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Files extracted!${NC}"
    echo ""
fi

# Check if moltron already exists in target
if [ -d "$TARGET_DIR/moltron" ]; then
    echo -e "${YELLOW}⚠️  Moltron skill already exists at destination.${NC}"
    echo -e "${YELLOW}   This will ${BOLD}overwrite${NC}${YELLOW} the existing installation.${NC}"
    echo ""
    
    # Auto-yes mode for non-interactive installs
    if [ "$AUTO_YES" = "true" ]; then
        echo -e "${BLUE}   Auto-yes mode enabled, proceeding...${NC}"
    else
        read -p "   Continue? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}ℹ️  Installation cancelled.${NC}"
            exit 0
        fi
    fi
    echo ""
fi

# Copy the moltron folder
echo -e "${BLUE}📦 Installing Moltron skill...${NC}"
cp -r "$SOURCE_DIR" "$TARGET_DIR/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✨ SUCCESS! ✨${NC}"
    echo ""
    echo -e "${GREEN}🎉 Moltron skill has been installed successfully!${NC}"
    echo ""
    echo -e "${CYAN}📝 Installation details:${NC}"
    if [ "$INSTALL_MODE" = "remote" ]; then
        echo -e "   From: ${MAGENTA}GitHub (${GITHUB_USER}/${GITHUB_REPO})${NC}"
    else
        echo -e "   From: ${MAGENTA}$SOURCE_DIR${NC}"
    fi
    echo -e "   To:   ${MAGENTA}$TARGET_DIR/moltron${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}Next steps:${NC}"
    echo -e "   1️⃣  Restart your OpenClaw agent (if running)"
    echo -e "   2️⃣  The Moltron skill should now be available"
    echo -e "   3️⃣  Your agents can now learn and evolve! 🚀"
    echo ""
else
    echo -e "${RED}❌ Installation failed!${NC}"
    echo -e "${YELLOW}   Please check permissions and try again.${NC}"
    exit 1
fi
