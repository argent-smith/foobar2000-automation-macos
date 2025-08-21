#!/bin/bash
#
# Git History Translation Script
# Translates all commit messages from Russian to English
#
# WARNING: This will rewrite git history and break existing clones!
# Make sure to coordinate with all collaborators before running.
#

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Function to translate a commit message using sed patterns
translate_commit_message() {
    local original_message="$1"
    
    # Apply translations using sed for proper encoding handling
    echo "$original_message" | sed -E '
        # Main action verbs
        s/Добавление/Add/g
        s/Добавлен/Add/g  
        s/Добавлена/Add/g
        s/Создание/Create/g
        s/Создан/Create/g
        s/Создана/Create/g
        s/Исправление/Fix/g
        s/Исправлен/Fix/g
        s/Исправлена/Fix/g
        s/Обновление/Update/g
        s/Обновлен/Update/g
        s/Обновлена/Update/g
        s/Удаление/Remove/g
        s/Удален/Remove/g
        s/Удалена/Remove/g
        s/Замена/Replace/g
        s/Заменен/Replace/g
        s/Заменена/Replace/g
        
        # Technical terms
        s/скрипта/script/g
        s/скриптов/scripts/g
        s/файла/file/g
        s/файлов/files/g
        s/папки/folder/g
        s/папок/folders/g
        s/документации/documentation/g
        s/конфигурации/configuration/g
        s/настройки/settings/g
        s/интеграции/integration/g
        s/мониторинга/monitoring/g
        s/конвертации/conversion/g
        s/установки/installation/g
        s/валидации/validation/g
        
        # Specific project terms
        s/массовой конвертации/batch conversion/g
        s/критических багов/critical bugs/g
        s/недостающих скриптов/missing scripts/g
        s/Python скрипта/Python script/g
        s/bash решение/bash solution/g
        s/log-файлов/log files/g
        s/архитектуры проекта/project architecture/g
        s/языковые требования/language requirements/g
        
        # Common phrases
        s/для macOS/for macOS/g
        s/на bash/to bash/g
        s/в английский/to English/g
        s/по-русски/in Russian/g
        s/недостающих/missing/g
        s/критические/critical/g
        s/исправлены/fixed/g
        s/баги/bugs/g
        s/рекурсивной/recursive/g
        s/символической ссылки/symbolic link/g
        s/игнорирование/ignoring/g
        s/требование/requirement/g
        s/руководство/guidelines/g
        s/наработки/work progress/g
        s/зависимости/dependencies/g
        s/альтернативы/alternatives/g
        s/проблемы/issues/g
        s/решения/solutions/g
        
        # Full common commit message patterns  
        s/Первоначальный коммит/Initial commit/g
        s/Исправлены критические баги/Fix critical bugs/g
        s/зафиксируй наработки/commit work progress/g
        
        # Git-specific terms
        s/коммит/commit/g
        s/коммита/commit/g
        s/коммитим/commit/g
        s/субмодуль/submodule/g
        s/субмодуля/submodule/g
        s/репозиторий/repository/g
        s/репозитория/repository/g
        s/ветка/branch/g
        s/ветки/branch/g
    '
}

# Main function to rewrite git history
rewrite_git_history() {
    echo -e "${BLUE}Starting git history translation...${NC}"
    
    # Safety check
    if [[ -z "${FORCE_REWRITE:-}" ]]; then
        echo -e "${RED}WARNING: This will rewrite git history!${NC}"
        echo -e "${YELLOW}This operation will:${NC}"
        echo -e "  - Change all commit hashes"
        echo -e "  - Break existing clones and forks" 
        echo -e "  - Require force push to remote"
        echo
        echo -e "Set FORCE_REWRITE=1 to proceed"
        exit 1
    fi
    
    # Create backup branch
    local backup_branch="backup-before-translation-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Creating backup branch: $backup_branch${NC}"
    git branch "$backup_branch"
    
    echo -e "${BLUE}Rewriting commit messages...${NC}"
    
    # Create temporary script for git filter-branch
    local temp_script=$(mktemp)
    cat > "$temp_script" << 'EOF'
#!/bin/bash
read msg
echo "$msg" | sed -E '
    # Main action verbs
    s/Добавление/Add/g
    s/Добавлен/Add/g  
    s/Добавлена/Add/g
    s/Создание/Create/g
    s/Создан/Create/g
    s/Создана/Create/g
    s/Исправление/Fix/g
    s/Исправлен/Fix/g
    s/Исправлена/Fix/g
    s/Обновление/Update/g
    s/Обновлен/Update/g
    s/Обновлена/Update/g
    s/Удаление/Remove/g
    s/Удален/Remove/g
    s/Удалена/Remove/g
    s/Замена/Replace/g
    s/Заменен/Replace/g
    s/Заменена/Replace/g
    
    # Technical terms
    s/скрипта/script/g
    s/скриптов/scripts/g
    s/файла/file/g
    s/файлов/files/g
    s/папки/folder/g
    s/папок/folders/g
    s/документации/documentation/g
    s/конфигурации/configuration/g
    s/настройки/settings/g
    s/интеграции/integration/g
    s/мониторинга/monitoring/g
    s/конвертации/conversion/g
    s/установки/installation/g
    s/валидации/validation/g
    
    # Specific project terms
    s/массовой конвертации/batch conversion/g
    s/критических багов/critical bugs/g
    s/недостающих скриптов/missing scripts/g
    s/Python скрипта/Python script/g
    s/bash решение/bash solution/g
    s/log-файлов/log files/g
    s/архитектуры проекта/project architecture/g
    s/языковые требования/language requirements/g
    
    # Common phrases
    s/для macOS/for macOS/g
    s/на bash/to bash/g
    s/в английский/to English/g
    s/по-русски/in Russian/g
    s/недостающих/missing/g
    s/критические/critical/g
    s/исправлены/fixed/g
    s/баги/bugs/g
    s/рекурсивной/recursive/g
    s/символической ссылки/symbolic link/g
    s/игнорирование/ignoring/g
    s/требование/requirement/g
    s/руководство/guidelines/g
    s/наработки/work progress/g
    s/зависимости/dependencies/g
    s/альтернативы/alternatives/g
    s/проблемы/issues/g
    s/решения/solutions/g
    
    # Full common commit message patterns  
    s/Первоначальный коммит/Initial commit/g
    s/Исправлены критические баги/Fix critical bugs/g
    s/зафиксируй наработки/commit work progress/g
    
    # Git-specific terms
    s/коммит/commit/g
    s/коммита/commit/g
    s/коммитим/commit/g
    s/субмодуль/submodule/g
    s/субмодуля/submodule/g
    s/репозиторий/repository/g
    s/репозитория/repository/g
    s/ветка/branch/g
    s/ветки/branch/g
'
EOF
    
    chmod +x "$temp_script"
    
    # Use git filter-branch to rewrite commit messages
    git filter-branch -f --msg-filter "$temp_script" HEAD
    
    # Clean up
    rm "$temp_script"
    
    echo -e "${GREEN}Git history translation completed!${NC}"
    echo -e "${YELLOW}Backup branch created: $backup_branch${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "1. Review translated commit messages: git log --oneline"
    echo -e "2. Test that everything works correctly"  
    echo -e "3. Force push to remote: git push --force-with-lease origin master"
    echo -e "4. Notify collaborators about history rewrite"
}

# Preview function to show what will be translated
preview_translations() {
    echo -e "${BLUE}Preview of commit message translations:${NC}"
    echo
    
    git log --pretty=format:"%h %s" | head -20 | while read -r hash message; do
        translated=$(translate_commit_message "$message")
        if [[ "$message" != "$translated" ]]; then
            echo -e "${YELLOW}$hash${NC} $message"
            echo -e "${GREEN}$hash${NC} $translated"
            echo
        fi
    done
}

# Help function
show_help() {
    echo "Git History Translation Script"
    echo
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  --preview     Show preview of translations without making changes"
    echo "  --rewrite     Perform actual git history rewrite (requires FORCE_REWRITE=1)"
    echo "  --help        Show this help message"
    echo
    echo "Example:"
    echo "  $0 --preview"
    echo "  FORCE_REWRITE=1 $0 --rewrite"
}

# Main script logic
case "${1:-}" in
    --preview)
        preview_translations
        ;;
    --rewrite)
        rewrite_git_history  
        ;;
    --help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Invalid option. Use --help for usage information.${NC}"
        exit 1
        ;;
esac