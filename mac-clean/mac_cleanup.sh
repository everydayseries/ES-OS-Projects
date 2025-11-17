#!/bin/bash

# Mac Development Environment Cleanup Script
# This script removes temporary files, build artifacts, and cached data
# from various development environments and system locations

set -e  # Exit on any error

# Script modes
INTERACTIVE_MODE=true
FORCE_MODE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to convert size to bytes for calculation
size_to_bytes() {
    local size="$1"
    # Remove any spaces and normalize
    size=$(echo "$size" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

    if [[ "$size" =~ ^([0-9.]+)([KMGT]?)B?$ ]]; then
        local number="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"
        case "$unit" in
            "K") echo $(awk "BEGIN {printf \"%.0f\", $number * 1024}") ;;
            "M") echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024}") ;;
            "G") echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024 * 1024}") ;;
            "T") echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024 * 1024 * 1024}") ;;
            *) echo $(awk "BEGIN {printf \"%.0f\", $number}") ;;
        esac
    else
        echo "0"
    fi
}

# Function to convert bytes back to human readable
bytes_to_human() {
    local bytes="$1"
    if [ "$bytes" -eq 0 ]; then
        echo "0B"
    elif [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$((bytes / 1024))K"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$((bytes / 1048576))M"
    else
        # For GB, use a simpler calculation
        local gb=$((bytes / 1073741824))
        local remainder=$((bytes % 1073741824))
        local decimal=$((remainder * 10 / 1073741824))
        echo "${gb}.${decimal}G"
    fi
}

# Function to get directory size in human readable format
get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "0B"
    fi
}

# Function to preview what will be cleaned
preview_cleanup() {
    local paths=("$@")
    local found_any=false
    local category_total_bytes=0

    echo -e "${BLUE}📋 Files/directories that will be cleaned:${NC}"

    for path in "${paths[@]}"; do
        if [[ "$path" == *"*"* ]]; then
            # Handle wildcard paths
            local base_path="${path%/*}"
            if [ -d "$base_path" ]; then
                local count=0
                local items_shown=0

                # Count total items first
                count=$(find "$base_path" -maxdepth 1 2>/dev/null | grep -v "^$base_path$" | wc -l | tr -d ' ')

                if [ "$count" -gt 0 ]; then
                    found_any=true
                    # Show first 10 items and calculate their sizes
                    find "$base_path" -maxdepth 1 2>/dev/null | grep -v "^$base_path$" | head -10 | while read -r item; do
                        local size=$(get_size "$item")
                        echo "   📁 $item ($size)"
                        local bytes=$(size_to_bytes "$size")
                        category_total_bytes=$((category_total_bytes + bytes))
                    done

                    # Add remaining items' sizes
                    if [ "$count" -gt 10 ]; then
                        echo "   ... and $((count - 10)) more items"
                        find "$base_path" -maxdepth 1 2>/dev/null | grep -v "^$base_path$" | tail -n +11 | while read -r item; do
                            local size=$(get_size "$item")
                            local bytes=$(size_to_bytes "$size")
                            category_total_bytes=$((category_total_bytes + bytes))
                        done
                    fi
                fi
            fi
        else
            if [ -e "$path" ]; then
                found_any=true
                local size=$(get_size "$path")
                echo "   📁 $path ($size)"
                local bytes=$(size_to_bytes "$size")
                category_total_bytes=$((category_total_bytes + bytes))
            fi
        fi
    done

    if [ "$found_any" = false ]; then
        echo "   ✅ No items found to clean"
        return 1
    fi

    # Show category total
    local category_total_human=$(bytes_to_human "$category_total_bytes")
    echo -e "${GREEN}💾 Total size in this category: $category_total_human${NC}"
    echo

    # Add to global total
    TOTAL_SIZE_BEFORE=$((TOTAL_SIZE_BEFORE + category_total_bytes))

    return 0
}

# Function to ask user for confirmation with preview
ask_user() {
    local message="$1"
    shift
    local paths=("$@")

    if [ "$FORCE_MODE" = true ]; then
        return 0
    fi

    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}$message${NC}"

        # Show preview if paths provided
        if [ ${#paths[@]} -gt 0 ]; then
            echo -e "${RED}[DEBUG ASK_USER]${NC} About to call preview_cleanup with ${#paths[@]} paths: ${paths[*]}"
            if ! preview_cleanup "${paths[@]}"; then
                echo -e "${GREEN}Nothing to clean in this category.${NC}"
                echo
                return 1
            fi
        else
            echo -e "${RED}[DEBUG ASK_USER]${NC} No paths provided to ask_user function"
        fi

        read -p "Proceed? (y/N/a=all/s=skip_all): " -n 1 -r
        echo
        case $REPLY in
            [Yy]) return 0 ;;
            [Aa]) FORCE_MODE=true; return 0 ;;
            [Ss]) INTERACTIVE_MODE=false; return 1 ;;
            *) return 1 ;;
        esac
    else
        return 1
    fi
}

# Function to safely remove directories/files
safe_remove() {
    local path="$1"
    local description="$2"
    local category="${3:-general}"

    if [ -e "$path" ]; then
        local size=$(get_size "$path")
        local bytes=$(size_to_bytes "$size")

        if ask_user "Remove $description ($size): $path"; then
            print_status "Removing $description ($size): $path"
            rm -rf "$path"
            print_success "Removed $description"

            # Add to reclaimed space (ensure variable is initialized)
            TOTAL_SIZE_AFTER=${TOTAL_SIZE_AFTER:-0}
            TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + bytes))
        else
            print_warning "Skipped $description"
        fi
    fi
}

# Function to find and remove directories by name
# find_and_remove() {
#     local dir_name="$1"
#     local description="$2"
#     local search_path="${3:-$HOME}"

#     # First, find all matching directories for preview
#     local found_dirs=()
#     while IFS= read -r -d '' dir; do
#         # Skip if it's a system directory or in /usr, /System, etc.
#         if [[ "$dir" =~ ^/System/ ]] || [[ "$dir" =~ ^/usr/ ]] || [[ "$dir" =~ ^/Library/Developer/CoreSimulator/ ]]; then
#             continue
#         fi
#         found_dirs+=("$dir")
#     done < <(find "$search_path" -type d -name "$dir_name" -print0 2>/dev/null)

#     if ! ask_user "Search and remove $description directories?" "${found_dirs[@]}"; then
#         print_warning "Skipped $description cleanup"
#         return
#     fi

#     print_status "Cleaning $description directories..."

#     # Now remove them
#     for dir in "${found_dirs[@]}"; do
#         if [ -d "$dir" ]; then
#             local size=$(get_size "$dir")
#             local bytes=$(size_to_bytes "$size")
#             print_status "Removing $description ($size): $dir"
#             rm -rf "$dir"
#             print_success "Removed $dir"

#             # Add to reclaimed space (ensure variable is initialized)
#             TOTAL_SIZE_AFTER=${TOTAL_SIZE_AFTER:-0}
#             TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + bytes))
#         fi
#     done
# }
find_and_remove() {
    local dir_name="$1"
    local description="$2"
    local search_path="${3:-$HOME}"

    print_status "Searching for $description directories..."

    # Find all matching directories
    local found_dirs=()
    local total_size_bytes=0

    # Use a more reliable method to collect directories
    while IFS= read -r dir; do
        # Skip if it's a system directory or in protected locations
        if [[ "$dir" =~ ^/System/ ]] || [[ "$dir" =~ ^/usr/ ]] || [[ "$dir" =~ ^/Library/Developer/CoreSimulator/ ]]; then
            continue
        fi

        # Skip if directory doesn't exist (race condition protection)
        if [ ! -d "$dir" ]; then
            continue
        fi

        found_dirs+=("$dir")

        # Calculate size for this directory
        local dir_size=$(du -sk "$dir" 2>/dev/null | cut -f1 || echo "0")
        total_size_bytes=$((total_size_bytes + dir_size * 1024))

    done < <(find "$search_path" -type d -name "$dir_name" 2>/dev/null)

    # If no directories found, report and return
    if [ ${#found_dirs[@]} -eq 0 ]; then
        print_status "No $description directories found"
        return 0
    fi

    # Show what was found
    echo -e "${BLUE}📋 Found ${#found_dirs[@]} $description directories:${NC}"
    local count=0
    for dir in "${found_dirs[@]}"; do
        if [ $count -lt 10 ]; then
            local size=$(get_size "$dir")
            echo "   📁 $dir ($size)"
        fi
        count=$((count + 1))
    done

    if [ ${#found_dirs[@]} -gt 10 ]; then
        echo "   ... and $((${#found_dirs[@]} - 10)) more directories"
    fi

    local total_human=$(bytes_to_human "$total_size_bytes")
    echo -e "${GREEN}💾 Total size: $total_human${NC}"
    echo

    # Add to global total for tracking
    TOTAL_SIZE_BEFORE=$((TOTAL_SIZE_BEFORE + total_size_bytes))

    # Ask for confirmation
    if [ "$FORCE_MODE" = true ]; then
        local proceed=true
    else
        read -p "Remove all these $description directories? (y/N/a=all/s=skip_all): " -n 1 -r
        echo
        case $REPLY in
            [Yy]) proceed=true ;;
            [Aa]) FORCE_MODE=true; proceed=true ;;
            [Ss]) INTERACTIVE_MODE=false; proceed=false ;;
            *) proceed=false ;;
        esac
    fi

    if [ "$proceed" = true ]; then
        print_status "Removing $description directories..."
        local removed_count=0
        local removed_size_bytes=0

        for dir in "${found_dirs[@]}"; do
            if [ -d "$dir" ]; then
                # Calculate size before removal
                local dir_size_kb=$(du -sk "$dir" 2>/dev/null | cut -f1 || echo "0")
                local dir_size_bytes=$((dir_size_kb * 1024))

                print_status "Removing: $dir ($(bytes_to_human $dir_size_bytes))"

                # Remove the directory
                if rm -rf "$dir" 2>/dev/null; then
                    removed_count=$((removed_count + 1))
                    removed_size_bytes=$((removed_size_bytes + dir_size_bytes))
                    print_success "✅ Removed: $dir"
                else
                    print_error "❌ Failed to remove: $dir"
                fi
            fi
        done

        # Update global total
        TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + removed_size_bytes))

        if [ $removed_count -gt 0 ]; then
            local removed_human=$(bytes_to_human "$removed_size_bytes")
            print_success "Removed $removed_count $description directories ($removed_human)"
        fi
    else
        print_warning "Skipped $description directories"
    fi
}

clean_node_modules() {
    local search_path="${1:-$HOME}"

    print_status "🔍 Searching for node_modules directories..."

    # Count first
    local count=$(find "$search_path" -type d -name "node_modules" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$count" -eq 0 ]; then
        print_status "No node_modules directories found"
        return 0
    fi

    echo -e "${YELLOW}Found $count node_modules directories${NC}"
    echo -e "${BLUE}ℹ️  Safety: ${YELLOW}⚠️  CAUTION${NC} - These can be recreated with 'npm install' but may take time"
    echo

    # Show first few examples
    echo "Examples:"
    find "$search_path" -type d -name "node_modules" 2>/dev/null | head -5 | while read -r dir; do
        size=$(get_size "$dir")
        echo "   📁 $dir ($size)"
    done

    if [ "$count" -gt 5 ]; then
        echo "   ... and $((count - 5)) more"
    fi
    echo

    if [ "$FORCE_MODE" = false ]; then
        read -p "Remove all node_modules directories? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Skipped node_modules cleanup"
            return 0
        fi
    fi

    print_status "Removing node_modules directories..."

    # Remove them
    local removed=0
    find "$search_path" -type d -name "node_modules" 2>/dev/null | while read -r dir; do
        if [ -d "$dir" ]; then
            size=$(get_size "$dir")
            print_status "Removing: $dir ($size)"

            if rm -rf "$dir" 2>/dev/null; then
                print_success "✅ Removed: $dir"
                removed=$((removed + 1))
            else
                print_error "❌ Failed to remove: $dir (permission denied?)"
            fi
        fi
    done

    print_success "Node.js modules cleanup completed"
}

echo "🧹 Mac Development Environment Cleanup Script"
echo "============================================="
echo

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_MODE=true
            INTERACTIVE_MODE=false
            print_status "Running in force mode (no prompts)"
            shift
            ;;
        -i|--interactive)
            INTERACTIVE_MODE=true
            FORCE_MODE=false
            print_status "Running in interactive mode"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force       Run without prompting (automatic yes to all)"
            echo "  -i, --interactive Run in interactive mode (default)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$INTERACTIVE_MODE" = true ]; then
    echo "💡 Interactive Mode Tips:"
    echo "   • y = yes to this item"
    echo "   • n = no to this item (default)"
    echo "   • a = yes to all remaining items"
    echo "   • s = skip all remaining items"
    echo
fi

# Check if running as root (not recommended)
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root is not recommended. Consider running as regular user."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Show disk space before cleanup
echo "💾 Disk Space Before Cleanup:"
df -h / | tail -1 | awk '{print "Available: " $4 " / Total: " $2}'
echo

print_status "Starting cleanup process..."

echo
echo -e "${BLUE}🛡️  SAFETY GUIDE:${NC}"
echo -e "${GREEN}✅ COMPLETELY SAFE${NC}     - Temporary files, caches (regenerate automatically)"
echo -e "${YELLOW}⚠️  CAUTION${NC}           - Development files (can rebuild, but takes time)"
echo -e "${RED}❌ BE CAREFUL${NC}        - Virtual environments, archives (hard to recover)"
echo
echo -e "${BLUE}💡 TIP: Start with safe categories first, then decide on others${NC}"
echo

# 1. System temporary files
if ask_user "🗑️  Clean system temporary files?" \
    "/tmp/*" \
    "$HOME/.Trash/*" \
    "/private/var/tmp/*"; then

    echo -e "${BLUE}ℹ️  Safety: ${GREEN}✅ COMPLETELY SAFE${NC} - These are temporary files that can always be safely deleted"
    echo

    print_status "🗑️  Cleaning system temporary files..."
    safe_remove "/tmp/*" "system temp files"
    safe_remove "$HOME/.Trash/*" "user trash"
    safe_remove "/private/var/tmp/*" "private temp files"
fi

# 2. macOS cache files
echo -e "${YELLOW}🍎 Clean macOS cache files?${NC}"

# Show safety information
echo -e "${BLUE}ℹ️  Safety Information:${NC}"
echo -e "${GREEN}   ✅ SAFE: Application caches - will be regenerated automatically${NC}"
echo -e "${GREEN}   ✅ SAFE: System logs (older than 7 days) - keeps recent for debugging${NC}"
echo -e "${YELLOW}   ⚠️  CAUTION: Crash reports - useful for debugging app issues${NC}"
echo -e "${GREEN}   ✅ SAFE: User logs - mostly diagnostic information${NC}"
echo

# Skip the complex function and calculate directly here
echo -e "${BLUE}📋 Files/directories that will be cleaned:${NC}"

# Show what will be cleaned
if [ -d "$HOME/Library/Caches" ]; then
    echo -e "${GREEN}   ✅ Directory: $HOME/Library/Caches (SAFE - apps will recreate)${NC}"
    find "$HOME/Library/Caches" -maxdepth 1 2>/dev/null | grep -v "^$HOME/Library/Caches$" | head -5 | while read -r item; do
        if [ -e "$item" ]; then
            size=$(get_size "$item")
            echo "   📁 $(basename "$item") ($size)"
        fi
    done
    cache_count=$(find "$HOME/Library/Caches" -maxdepth 1 2>/dev/null | grep -v "^$HOME/Library/Caches$" | wc -l | tr -d ' ')
    if [ "$cache_count" -gt 5 ]; then
        echo "   ... and $((cache_count - 5)) more cache directories"
    fi
fi

if [ -d "$HOME/Library/Application Support/CrashReporter" ]; then
    echo -e "${YELLOW}   ⚠️  Directory: $HOME/Library/Application Support/CrashReporter (CAUTION - keeps crash data)${NC}"
    crash_count=$(find "$HOME/Library/Application Support/CrashReporter" -maxdepth 1 2>/dev/null | grep -v "^$HOME/Library/Application Support/CrashReporter$" | wc -l | tr -d ' ')
    echo "   📁 CrashReporter ($crash_count files)"
fi

if [ -d "$HOME/Library/Logs" ]; then
    echo -e "${GREEN}   ✅ Directory: $HOME/Library/Logs (SAFE - diagnostic logs)${NC}"
    log_count=$(find "$HOME/Library/Logs" -maxdepth 1 2>/dev/null | grep -v "^$HOME/Library/Logs$" | wc -l | tr -d ' ')
    echo "   📁 User Logs ($log_count files)"
fi

if [ -d "/Library/Logs" ]; then
    echo -e "${GREEN}   ✅ Directory: /Library/Logs (SAFE - system logs)${NC}"
    sys_log_count=$(find "/Library/Logs" -maxdepth 1 2>/dev/null | grep -v "^/Library/Logs$" | wc -l | tr -d ' ')
    echo "   📁 System Logs ($sys_log_count files)"
fi

# Calculate total size directly
echo -e "${BLUE}[INFO]${NC} Calculating total size..."
total_kb=0

if [ -d "$HOME/Library/Caches" ]; then
    caches_kb=$(find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 -exec du -sk {} \; 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    echo -e "${BLUE}[INFO]${NC} Caches: ${caches_kb}KB"
    total_kb=$((total_kb + caches_kb))
fi

if [ -d "$HOME/Library/Application Support/CrashReporter" ]; then
    crash_kb=$(find "$HOME/Library/Application Support/CrashReporter" -mindepth 1 -maxdepth 1 -exec du -sk {} \; 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    echo -e "${BLUE}[INFO]${NC} CrashReporter: ${crash_kb}KB"
    total_kb=$((total_kb + crash_kb))
fi

if [ -d "$HOME/Library/Logs" ]; then
    user_logs_kb=$(find "$HOME/Library/Logs" -mindepth 1 -maxdepth 1 -exec du -sk {} \; 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    echo -e "${BLUE}[INFO]${NC} User Logs: ${user_logs_kb}KB"
    total_kb=$((total_kb + user_logs_kb))
fi

if [ -d "/Library/Logs" ]; then
    sys_logs_kb=$(find "/Library/Logs" -mindepth 1 -maxdepth 1 -exec du -sk {} \; 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    echo -e "${BLUE}[INFO]${NC} System Logs: ${sys_logs_kb}KB"
    total_kb=$((total_kb + sys_logs_kb))
fi

total_bytes=$((total_kb * 1024))
total_human=$(bytes_to_human "$total_bytes")

echo -e "${GREEN}💾 Total size in this category: $total_human${NC}"
echo

TOTAL_SIZE_BEFORE=${TOTAL_SIZE_BEFORE:-0}
TOTAL_SIZE_BEFORE=$((TOTAL_SIZE_BEFORE + total_bytes))

read -p "Proceed? (y/N/a=all/s=skip_all): " -n 1 -r
echo
case $REPLY in
    [Yy])
        print_status "🍎 Cleaning macOS cache files..."

        # Clean caches directory contents
        if [ -d "$HOME/Library/Caches" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning user caches..."
            find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned user caches"
        fi

        # Clean crash reporter files
        if [ -d "$HOME/Library/Application Support/CrashReporter" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning crash reports..."
            find "$HOME/Library/Application Support/CrashReporter" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned crash reports"
        fi

        # Clean user logs
        if [ -d "$HOME/Library/Logs" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning user logs..."
            find "$HOME/Library/Logs" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned user logs"
        fi

        # Clean system logs (need sudo for some)
        if [ -d "/Library/Logs" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning system logs..."
            find "/Library/Logs" -mindepth 1 -maxdepth 1 -type f -name "*.log" -exec rm -f {} + 2>/dev/null || true
            # Only clean specific safe system log directories
            if [ -d "/Library/Logs/DiagnosticReports" ]; then
                find "/Library/Logs/DiagnosticReports" -name "*.crash" -mtime +7 -exec rm -f {} + 2>/dev/null || true
            fi
            if [ -d "/Library/Logs/CrashReporter" ]; then
                find "/Library/Logs/CrashReporter" -name "*.crash" -mtime +7 -exec rm -f {} + 2>/dev/null || true
            fi
            print_success "Cleaned system logs"
        fi

        # Update the total reclaimed space
        #GG local cleaned_bytes=$((total_kb * 1024))
        TOTAL_SIZE_AFTER=${TOTAL_SIZE_AFTER:-0}
        TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + cleaned_bytes))
        ;;
    [Aa])
        FORCE_MODE=true
        print_status "🍎 Cleaning macOS cache files..."

        # Same cleaning logic for "all" mode
        if [ -d "$HOME/Library/Caches" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning user caches..."
            find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned user caches"
        fi

        if [ -d "$HOME/Library/Application Support/CrashReporter" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning crash reports..."
            find "$HOME/Library/Application Support/CrashReporter" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned crash reports"
        fi

        if [ -d "$HOME/Library/Logs" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning user logs..."
            find "$HOME/Library/Logs" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
            print_success "Cleaned user logs"
        fi

        if [ -d "/Library/Logs" ]; then
            echo -e "${BLUE}[INFO]${NC} Cleaning system logs..."
            find "/Library/Logs" -mindepth 1 -maxdepth 1 -type f -name "*.log" -exec rm -f {} + 2>/dev/null || true
            if [ -d "/Library/Logs/DiagnosticReports" ]; then
                find "/Library/Logs/DiagnosticReports" -name "*.crash" -mtime +7 -exec rm -f {} + 2>/dev/null || true
            fi
            if [ -d "/Library/Logs/CrashReporter" ]; then
                find "/Library/Logs/CrashReporter" -name "*.crash" -mtime +7 -exec rm -f {} + 2>/dev/null || true
            fi
            print_success "Cleaned system logs"
        fi

        local cleaned_bytes=$((total_kb * 1024))
        TOTAL_SIZE_AFTER=${TOTAL_SIZE_AFTER:-0}
        TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + cleaned_bytes))
        ;;
    [Ss])
        INTERACTIVE_MODE=false
        ;;
    *)
        print_warning "Skipped macOS cache files"
        ;;
esac

# 3. Browser caches (major browsers)
if ask_user "🌐 Clean browser caches?" \
    "$HOME/Library/Caches/com.apple.Safari/*" \
    "$HOME/Library/Caches/Google/Chrome/*" \
    "$HOME/Library/Caches/com.google.Chrome/*" \
    "$HOME/Library/Caches/Mozilla/*" \
    "$HOME/Library/Application Support/Google/Chrome/Default/Service Worker/*"; then

    echo -e "${BLUE}ℹ️  Safety: ${GREEN}✅ SAFE${NC} - Browser caches will be recreated. You may need to re-login to some websites."
    echo

    print_status "🌐 Cleaning browser caches..."
    safe_remove "$HOME/Library/Caches/com.apple.Safari/*" "Safari cache"
    safe_remove "$HOME/Library/Caches/Google/Chrome/*" "Chrome cache"
    safe_remove "$HOME/Library/Caches/com.google.Chrome/*" "Chrome cache (alt)"
    safe_remove "$HOME/Library/Caches/Mozilla/*" "Firefox cache"
    safe_remove "$HOME/Library/Application Support/Google/Chrome/Default/Service Worker/*" "Chrome service workers"
fi

# 4. Development environment cleanups
if ask_user "👨‍💻 Clean development environments?"; then
    print_status "👨‍💻 Cleaning development environments..."

    # Node.js
    if ask_user "📦 Clean Node.js artifacts (node_modules, .next, npm cache, etc.)?" \
        "$HOME/.npm/_cacache" \
        "$HOME/.yarn/cache" \
        "$HOME/.pnpm-store"; then

        echo -e "${BLUE}ℹ️  Safety: ${YELLOW}⚠️  CAUTION${NC} - node_modules can be recreated with 'npm install', but may take time"
        echo

        print_status "📦 Cleaning Node.js artifacts..."
        clean_node_modules "$HOME"
        # find_and_remove "node_modules" "Node.js modules"
        find_and_remove ".next" "Next.js build"
        find_and_remove ".nuxt" "Nuxt.js build"
        find_and_remove "dist" "build dist folders"
        find_and_remove "build" "build folders"
        safe_remove "$HOME/.npm/_cacache" "npm cache"
        safe_remove "$HOME/.yarn/cache" "yarn cache"
        safe_remove "$HOME/.pnpm-store" "pnpm store"
    fi

    # Python
    if ask_user "🐍 Clean Python artifacts (.venv, __pycache__, pip cache, etc.)?" \
        "$HOME/.cache/pip" \
        "$HOME/Library/Caches/pip"; then

        echo -e "${BLUE}ℹ️  Safety: ${RED}❌ BE CAREFUL${NC} - .venv folders contain your Python environments and packages"
        echo -e "${YELLOW}   Consider backing up important virtual environments first${NC}"
        echo

        print_status "🐍 Cleaning Python artifacts..."
        find_and_remove ".venv" "Python virtual environments"
        find_and_remove "venv" "Python virtual environments"
        find_and_remove "__pycache__" "Python cache"
        find_and_remove ".pytest_cache" "pytest cache"
        find_and_remove ".coverage" "coverage files"
        safe_remove "$HOME/.cache/pip" "pip cache"
        safe_remove "$HOME/Library/Caches/pip" "pip cache (macOS)"
    fi

    # Flutter/Dart
    if ask_user "🎯 Clean Flutter/Dart artifacts?" \
        "$HOME/.pub-cache"; then
        print_status "🎯 Cleaning Flutter/Dart artifacts..."
        safe_remove "$HOME/.pub-cache" "Dart pub cache"
        find_and_remove ".dart_tool" "Dart tool cache"
        find_and_remove "build" "Flutter build folders" "$HOME/flutter_projects"
    fi

    # iOS Development
    if ask_user "📱 Clean iOS development artifacts (Xcode caches, derived data)?" \
        "$HOME/Library/Developer/Xcode/DerivedData" \
        "$HOME/Library/Caches/com.apple.dt.Xcode" \
        "$HOME/Library/Developer/Xcode/Archives" \
        "$HOME/Library/Developer/CoreSimulator/Caches"; then

        echo -e "${BLUE}ℹ️  Safety: ${GREEN}✅ MOSTLY SAFE${NC} - Will slow down next Xcode build but saves significant space"
        echo -e "${YELLOW}   Archives contain your app builds for App Store - consider backing up first${NC}"
        echo

        print_status "📱 Cleaning iOS development artifacts..."
        safe_remove "$HOME/Library/Developer/Xcode/DerivedData" "Xcode derived data"
        safe_remove "$HOME/Library/Caches/com.apple.dt.Xcode" "Xcode cache"
        safe_remove "$HOME/Library/Developer/Xcode/Archives" "Xcode archives"
        safe_remove "$HOME/Library/Developer/CoreSimulator/Caches" "iOS Simulator cache"
    fi

    # Android Development
    if ask_user "🤖 Clean Android development artifacts?" \
        "$HOME/.android/cache" \
        "$HOME/.gradle/caches" \
        "$HOME/.gradle/daemon"; then
        print_status "🤖 Cleaning Android development artifacts..."
        safe_remove "$HOME/.android/cache" "Android SDK cache"
        safe_remove "$HOME/.gradle/caches" "Gradle cache"
        safe_remove "$HOME/.gradle/daemon" "Gradle daemon"
    fi

    # Ruby
    if ask_user "💎 Clean Ruby artifacts?" \
        "$HOME/.gem/cache" \
        "$HOME/.bundle/cache"; then
        print_status "💎 Cleaning Ruby artifacts..."
        safe_remove "$HOME/.gem/cache" "Ruby gem cache"
        safe_remove "$HOME/.bundle/cache" "Bundler cache"
    fi

    # Rust
    if ask_user "🦀 Clean Rust artifacts?" \
        "$HOME/.cargo/registry/cache"; then
        print_status "🦀 Cleaning Rust artifacts..."
        find_and_remove "target" "Rust target folders"
        safe_remove "$HOME/.cargo/registry/cache" "Cargo registry cache"
    fi

    # Go
    if ask_user "🐹 Clean Go artifacts?" \
        "$HOME/go/pkg/mod/cache"; then
        print_status "🐹 Cleaning Go artifacts..."
        safe_remove "$HOME/go/pkg/mod/cache" "Go module cache"
    fi

    # Docker
    if ask_user "🐳 Clean Docker artifacts?"; then
        print_status "🐳 Cleaning Docker artifacts..."
        if command -v docker &> /dev/null; then
            print_status "Cleaning Docker system..."
            docker system prune -f 2>/dev/null || print_warning "Docker cleanup failed or not running"
        fi
    fi

    # Git
    if ask_user "📝 Clean Git repositories (garbage collection)?"; then
        print_status "📝 Cleaning Git artifacts..."
        find "$HOME" -name ".git" -type d 2>/dev/null | while read -r git_dir; do
            if [ -f "$git_dir/config" ]; then
                repo_dir=$(dirname "$git_dir")
                print_status "Cleaning Git repository: $repo_dir"
                (cd "$repo_dir" && git gc --aggressive --prune=now 2>/dev/null) || true
            fi
        done
    fi
fi

# IDE/Editor caches
if ask_user "📝 Clean IDE/Editor caches?" \
    "$HOME/Library/Caches/JetBrains" \
    "$HOME/.vscode/extensions/.obsolete" \
    "$HOME/Library/Application Support/Code/CachedData" \
    "$HOME/Library/Application Support/Code/logs"; then
    print_status "📝 Cleaning IDE/Editor caches..."
    safe_remove "$HOME/Library/Caches/JetBrains" "JetBrains IDE cache"
    safe_remove "$HOME/.vscode/extensions/.obsolete" "VS Code obsolete extensions"
    safe_remove "$HOME/Library/Application Support/Code/CachedData" "VS Code cached data"
    safe_remove "$HOME/Library/Application Support/Code/logs" "VS Code logs"
fi

# Homebrew
if ask_user "🍺 Clean Homebrew cache?"; then
    print_status "🍺 Cleaning Homebrew..."
    if command -v brew &> /dev/null; then
        print_status "Running brew cleanup..."
        brew cleanup 2>/dev/null || print_warning "Homebrew cleanup failed"
    fi
fi

# Additional system cleanup
if ask_user "🧽 Additional system cleanup?" \
    "$HOME/Library/Application Support/SyncServices" \
    "$HOME/Library/PubSub" \
    "$HOME/Library/Suggestions"; then
    print_status "🧽 Additional system cleanup..."
    if [ -d "$HOME/Library/Application Support/SyncServices" ]; then
     rm -rf "$HOME/Library/Application Support/SyncServices" 2>/dev/null || true
    print_success "Removed sync services"
    fi

    if [ -d "$HOME/Library/PubSub" ]; then
      rm -rf "$HOME/Library/PubSub" 2>/dev/null || true
    print_success "Removed pub sub database"
    fi

    # Skip Suggestions - it's system protected
    print_warning "Skipped system-protected Suggestions database"
fi

# Clean up empty directories
if ask_user "🗂️  Remove empty directories?"; then
    print_status "🗂️  Removing empty directories..."
    find "$HOME" -type d -empty -not -path "*/.*" 2>/dev/null | head -20 | while read -r empty_dir; do
        if [[ ! "$empty_dir" =~ ^/System/ ]] && [[ ! "$empty_dir" =~ ^/usr/ ]]; then
            print_status "Removing empty directory: $empty_dir"
            rmdir "$empty_dir" 2>/dev/null || true
        fi
    done
fi

echo
print_success "✅ Cleanup completed!"

# Show space reclaimed summary
if [ "${TOTAL_SIZE_AFTER:-0}" -gt 0 ]; then
    reclaimed_human=$(bytes_to_human "$TOTAL_SIZE_AFTER")
    echo
    echo -e "${GREEN}🎉 Space Successfully Reclaimed: $reclaimed_human${NC}"

    if [ "${TOTAL_SIZE_BEFORE:-0}" -gt 0 ]; then
        percentage=$((TOTAL_SIZE_AFTER * 100 / TOTAL_SIZE_BEFORE))
        echo -e "${BLUE}📈 Cleanup Efficiency: $percentage% of identified files were cleaned${NC}"
    fi
else
    echo
    echo -e "${YELLOW}ℹ️  No files were actually removed (user skipped or no files found)${NC}"
fi

# Show potential space that could be reclaimed
if [ "${TOTAL_SIZE_BEFORE:-0}" -gt 0 ]; then
    total_before_human=$(bytes_to_human "$TOTAL_SIZE_BEFORE")
    echo -e "${BLUE}📊 Total space identified for cleanup: $total_before_human${NC}"
fi

# Show disk space after cleanup
echo
echo "💾 Disk Space After Cleanup:"
df -h / | tail -1 | awk '{print "Available: " $4 " / Total: " $2}'

echo
print_status "🚀 Recommendations:"
echo "   • Restart your computer for optimal performance"
echo "   • Run this script regularly (weekly/monthly)"
echo "   • Consider using 'sudo purge' to clear memory cache"
echo "   • Check Activity Monitor for resource-heavy applications"

if [ "$TOTAL_SIZE_AFTER" -gt 0 ]; then
    echo
    print_success "🎉 Your Mac should now have more free space and run smoother!"
else
    echo
    print_status "💡 Run the script again with different options to clean more files"
fi
