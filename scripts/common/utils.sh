#!/bin/bash

# Common utility functions for Node.js installation scripts
# Source this file in your installation scripts: source ./common/utils.sh

# Color constants
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export PURPLE='\033[0;35m'
export NC='\033[0m' # No Color

# Print functions
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${CYAN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_debug() { echo -e "${PURPLE}[DEBUG] $1${NC}"; }

# Progress bar function
show_progress() {
    local duration=$1
    local message=$2
    
    for ((i=0; i<=duration; i++)); do
        local percent=$((i * 100 / duration))
        local filled=$((percent / 5))
        local empty=$((20 - filled))
        
        printf "\r${CYAN}$message [${GREEN}%*s%*s${CYAN}] %d%%${NC}" \
               "$filled" "$(printf "%${filled}s" | tr ' ' '=')" \
               "$empty" "" "$percent"
        
        sleep 0.1
    done
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root/sudo
is_root() {
    [[ $EUID -eq 0 ]]
}

# Get OS information
get_os_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check internet connectivity
check_internet() {
    print_info "Checking internet connectivity..."
    
    if command_exists curl; then
        if curl -s --max-time 10 https://www.google.com > /dev/null; then
            print_success "Internet connection verified"
            return 0
        fi
    elif command_exists wget; then
        if wget -q --timeout=10 --tries=1 --spider https://www.google.com; then
            print_success "Internet connection verified"
            return 0
        fi
    elif command_exists ping; then
        if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
            print_success "Internet connection verified"
            return 0
        fi
    fi
    
    print_error "No internet connection detected"
    return 1
}

# Check available disk space (in GB)
check_disk_space() {
    local required_space=${1:-2} # Default 2GB
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local available=$(df -g . | tail -1 | awk '{print $4}')
    else
        local available=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    fi
    
    if (( available >= required_space )); then
        print_success "Sufficient disk space: ${available}GB available"
        return 0
    else
        print_error "Insufficient disk space: ${available}GB available, ${required_space}GB required"
        return 1
    fi
}

# Backup existing configuration file
backup_config() {
    local config_file=$1
    
    if [[ -f "$config_file" ]]; then
        local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        print_success "Backed up $config_file to $backup_file"
    fi
}

# Download file with progress
download_file() {
    local url=$1
    local output=$2
    local description=${3:-"file"}
    
    print_info "Downloading $description..."
    
    if command_exists curl; then
        curl -L --progress-bar "$url" -o "$output"
    elif command_exists wget; then
        wget --progress=bar:force "$url" -O "$output"
    else
        print_error "Neither curl nor wget is available"
        return 1
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "$description downloaded successfully"
        return 0
    else
        print_error "Failed to download $description"
        return 1
    fi
}

# Verify file checksum
verify_checksum() {
    local file=$1
    local expected_checksum=$2
    local algorithm=${3:-"sha256"}
    
    if ! command_exists "${algorithm}sum"; then
        print_warning "Cannot verify checksum: ${algorithm}sum not available"
        return 0
    fi
    
    local actual_checksum
    actual_checksum=$("${algorithm}sum" "$file" | cut -d' ' -f1)
    
    if [[ "$actual_checksum" == "$expected_checksum" ]]; then
        print_success "Checksum verification passed"
        return 0
    else
        print_error "Checksum verification failed"
        print_error "Expected: $expected_checksum"
        print_error "Actual:   $actual_checksum"
        return 1
    fi
}

# Add line to file if not exists
add_to_file() {
    local line=$1
    local file=$2
    
    if ! grep -Fxq "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        print_success "Added configuration to $file"
    else
        print_info "Configuration already exists in $file"
    fi
}

# Create directory with parents
create_dir() {
    local dir=$1
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    else
        print_info "Directory already exists: $dir"
    fi
}

# Wait for user input
wait_for_input() {
    local message=${1:-"Press any key to continue..."}
    echo -e "${YELLOW}$message${NC}"
    read -n 1 -s
}

# Confirm action
confirm() {
    local message=${1:-"Do you want to continue?"}
    local default=${2:-"y"}
    
    if [[ "$default" == "y" ]]; then
        local prompt="$message (Y/n): "
    else
        local prompt="$message (y/N): "
    fi
    
    while true; do
        echo -ne "${YELLOW}$prompt${NC}"
        read -r response
        
        case "$response" in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            "" ) 
                if [[ "$default" == "y" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "Please answer yes or no." ;;
        esac
    done
}

# Log function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${LOG_FILE:-/tmp/node-install.log}"
    
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    case "$level" in
        ERROR) print_error "$message" ;;
        WARNING) print_warning "$message" ;;
        INFO) print_info "$message" ;;
        SUCCESS) print_success "$message" ;;
        DEBUG) [[ "${DEBUG:-}" == "true" ]] && print_debug "$message" ;;
        *) echo "$message" ;;
    esac
}

# Cleanup function
cleanup() {
    local temp_files=("$@")
    
    for file in "${temp_files[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            print_info "Cleaned up temporary file: $file"
        fi
    done
}

# Set trap for cleanup on exit
set_cleanup_trap() {
    trap 'cleanup "$@"' EXIT
}

# Check system requirements
check_requirements() {
    local requirements=(
        "curl:Download tool"
        "git:Version control"
        "tar:Archive extraction"
        "gzip:Compression tool"
    )
    
    local missing=()
    
    print_info "Checking system requirements..."
    
    for req in "${requirements[@]}"; do
        local cmd="${req%%:*}"
        local desc="${req##*:}"
        
        if command_exists "$cmd"; then
            print_success "$desc ($cmd) is available"
        else
            print_warning "$desc ($cmd) is missing"
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "All requirements satisfied"
        return 0
    else
        print_error "Missing requirements: ${missing[*]}"
        return 1
    fi
}

# Export functions for use in other scripts
export -f print_success print_info print_warning print_error print_debug
export -f command_exists is_root get_os_info check_internet check_disk_space
export -f backup_config download_file verify_checksum add_to_file create_dir
export -f wait_for_input confirm log cleanup set_cleanup_trap check_requirements
export -f show_progress
