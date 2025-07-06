# Contributing to Window Glue

Thank you for your interest in contributing to Window Glue! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature or bug fix
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Development Setup

### Requirements
- Xcode 15.0 or later
- macOS 14.0 (Sonoma) or later
- Swift 5.9+

### Building
1. Open `Window Glue.xcodeproj` in Xcode
2. Select the Window Glue scheme
3. Build and run (⌘+R)

### Dependencies
The project uses Swift Package Manager for dependencies:
- [Swindler](https://github.com/tmandry/Swindler) - Window management
- [AXSwift](https://github.com/tmandry/AXSwift) - Accessibility API wrapper
- [PromiseKit](https://github.com/mxcl/PromiseKit) - Asynchronous programming
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global keyboard shortcuts

## Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- Use SwiftUI best practices

## Testing

- Test on multiple macOS versions if possible
- Verify accessibility permissions work correctly
- Test with various window configurations
- Ensure keyboard shortcuts work as expected

## Submitting Changes

### Pull Request Process
1. Ensure your code builds without warnings
2. Test your changes thoroughly
3. Update documentation if needed
4. Create a clear pull request description
5. Link any related issues

### Commit Messages
- Use clear, descriptive commit messages
- Start with a verb in present tense
- Keep the first line under 50 characters
- Add detailed description if needed

Example:
```
Add keyboard shortcut customization

- Allow users to set custom shortcuts in settings
- Default shortcuts remain F9 and Shift+F9
- Validate shortcut conflicts
```

## Reporting Issues

When reporting bugs, please include:
- macOS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if relevant
- Console logs if applicable

## Feature Requests

For feature requests:
- Check if it already exists in issues
- Describe the use case clearly
- Explain why it would benefit users
- Consider implementation complexity

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the issue, not the person
- Help create a positive community

## Questions?

Feel free to open an issue for any questions about contributing!