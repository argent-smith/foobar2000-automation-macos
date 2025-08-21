# Translation Plan - Project Localization to English

## Status Overview

### Completed ✅
- **Documentation Files**
  - README.md - Fully translated
  - BUGFIXES.md - Fully translated  
  - CHANGELOG.md - Fully translated
  - CLAUDE.md - Already in English + added language guidelines
  - docs/monitor_alternatives.md - Fully translated

- **Fish Shell Interface**
  - scripts/foobar2000_fish_functions.fish - User-facing text translated

### In Progress 🔄

#### Script Files Requiring Translation
1. **scripts/foobar_menu_fish.sh** - Interactive menu system
   - Status: High priority - contains extensive user interface text
   - User-facing messages in Russian need translation

2. **scripts/foobar_monitor.sh** - File monitoring system  
   - Status: Medium priority - log messages and user output
   - Color-coded status messages need translation

3. **scripts/convert_with_external_advanced.sh** - Advanced converter
   - Status: High priority - user prompts and error messages
   - Interactive mode messages need translation

4. **scripts/install.sh** - Main installation script
   - Status: High priority - installation prompts and status
   - Error messages and user guidance need translation

5. **scripts/validator.sh** - System validation
   - Status: Medium priority - validation output messages
   - Error reporting needs translation

6. **scripts/config-generator.sh** - Configuration generator
   - Status: Medium priority - generation status messages
   - User feedback needs translation

7. **scripts/components-downloader.sh** - Component installer
   - Status: Medium priority - installation progress messages
   - Download status needs translation

8. **scripts/foobar_integration_setup.sh** - Integration setup
   - Status: Low priority - mostly internal operations
   - Setup messages need translation

#### Configuration Files
1. **configs/presets/encoder_presets_macos.cfg**
   - Status: Medium priority - preset descriptions
   - Comment translations needed

2. **configs/scripts/MASSTAGGER_MACOS.txt**
   - Status: Low priority - script descriptions
   - Comments need translation

3. **configs/templates/macos_integration.cfg**
   - Status: Low priority - template comments
   - Documentation strings need translation

#### Resource Files
1. **resources/macos_components.json**
   - Status: Low priority - component descriptions
   - Description fields may need translation

2. **resources/compatibility_macos.json**
   - Status: Low priority - compatibility notes
   - Description fields may need translation

### Pending 📋

#### Git History Rewriting
- **All commit messages** from project inception need English translation
- **Branch names** if any contain non-English text
- **Tag messages** if any contain non-English text

#### File Structure Review
- Check if any **file names** contain non-English characters
- Verify **directory names** are appropriate for English project
- Review **symbolic links** for language-specific paths

## Implementation Strategy

### Phase 1: Critical User Interface (Priority 1)
Scripts with direct user interaction that must be translated first:
1. foobar_menu_fish.sh
2. convert_with_external_advanced.sh  
3. install.sh
4. foobar_monitor.sh

### Phase 2: System Scripts (Priority 2) 
Scripts with user feedback and error messages:
1. validator.sh
2. config-generator.sh
3. components-downloader.sh

### Phase 3: Configuration and Resources (Priority 3)
Files with descriptions and comments:
1. Configuration files in configs/
2. Resource description files
3. foobar_integration_setup.sh

### Phase 4: Git History (Priority 4)
Complete history rewrite:
1. Create translation mapping for all commit messages
2. Use `git filter-branch` or `git-filter-repo` for history rewrite
3. Force push rewritten history (breaking change)

## Translation Guidelines

### Text Categories
1. **User Interface Text**: Direct user prompts, menus, options
2. **Error Messages**: Error descriptions and troubleshooting hints  
3. **Status Messages**: Progress indicators and completion notices
4. **Comments**: Code comments and documentation strings
5. **Configuration**: Preset names, descriptions, and templates

### Technical Considerations
1. **Preserve Functionality**: Ensure translations don't break script logic
2. **Maintain Formatting**: Keep color codes, spacing, and alignment
3. **Path Consistency**: Update any language-specific file paths
4. **Variable Names**: Keep technical variable names in English/neutral
5. **Log Compatibility**: Ensure log parsing still works after translation

## Risk Assessment

### High Risk Operations
- **Git history rewrite**: Will invalidate existing clones/forks
- **Script translation**: Could introduce bugs if not carefully tested
- **Path changes**: Might break existing installations

### Mitigation Strategy
- Create backup branches before major changes
- Test each translated script individually
- Validate all functionality after translation
- Document breaking changes clearly

## Completion Criteria

### Definition of Done
- [ ] All user-visible text in English
- [ ] All comments and documentation in English  
- [ ] All commit messages in English
- [ ] All configuration descriptions in English
- [ ] Full functionality preserved
- [ ] No broken paths or references
- [ ] Updated installation instructions
- [ ] Migration guide for existing users

## Estimated Effort

### Time Estimates (Development Hours)
- Phase 1 (Critical UI): 8-12 hours
- Phase 2 (System Scripts): 6-8 hours  
- Phase 3 (Config/Resources): 4-6 hours
- Phase 4 (Git History): 4-6 hours
- **Total: 22-32 hours**

### Testing Requirements
- Full installation test on clean system
- All script functionality verification
- Fish shell integration testing
- Error handling validation

## Next Steps

1. **Complete Phase 1 scripts translation**
2. **Test translated scripts individually** 
3. **Proceed with Phase 2 and 3**
4. **Plan git history rewrite strategy**
5. **Execute complete translation**
6. **Comprehensive testing**
7. **Documentation updates**