# XID Tutorial Style Guide

This style guide provides a consistent standard for all XID tutorials. Following these guidelines ensures that tutorials are clear, maintainable, and provide a smooth learning experience.

## Tutorial Structure

Every tutorial should follow this structure:

1. **Title**: Clear, action-oriented (e.g., "Creating Your First XID")
2. **Introduction**: Brief overview of what the user will learn and build
3. **Time Estimate**: Approximate time to complete (e.g., "Time to complete: 15-20 minutes")
4. **Related Concepts**: Links to relevant concept documents
5. **Prerequisites**: Clear list of requirements
6. **What You'll Learn**: Bullet list of learning outcomes
7. **Context/Background**: Narrative context (where applicable)
8. **Numbered Steps**: Clear, sequential steps with descriptive headers
9. **Understanding Section**: Explanation of what happened and why
10. **Next Steps**: Pointer to the next tutorial in the sequence
11. **Exercises**: Optional additional tasks for practice

## Code Block Formatting

1. **Command Indicator**: All command blocks start with the 👉 emoji
2. **Output Indicator**: All output blocks start with the 🔍 emoji
3. **Syntax Highlighting**: Use `sh` for command blocks and `console` for output blocks
4. **Variable References**: Always use proper `$VARIABLE` syntax with $ before variable names
5. **Command Structure**:
   - One command per line when possible
   - Use line continuations (\\) for long commands
   - Include comments for complex commands
6. **Output Examples**:
   - Show realistic but concise outputs
   - Use ellipses (...) for truncated output when appropriate

Example:

```markdown
👉 
```sh
# Create a minimal XID
XID_DOC=$(envelope xid new --name "Example" "$PUBLIC_KEYS")
echo "$XID_DOC" > output/example.envelope
```

🔍 
```console
```

## Visual Formatting

1. **Bold for Emphasis**: Use **bold text** for important concepts
2. **Code Formatting**: Use `inline code` for commands, variables, and filenames
3. **Numbered Lists**: Use for sequential steps
4. **Bullet Lists**: Use for non-sequential items
5. **Headers**: Use proper hierarchy (H1 for title, H2 for main sections, H3 for subsections)
6. **Images**: Include diagrams when helpful (not overwhelming)

## Code Style

1. **Variables**:
   - Use ALL_CAPS for shell variables
   - Use descriptive names (e.g., `PUBLIC_KEYS` not `KEYS`)
   - Always use $ prefix when referencing variables
2. **Commands**:
   - Be consistent with flags (e.g., always use `--type tree` not `-t tree`)
   - Use long-form flags when improving readability
   - Keep commands consistent across tutorials
3. **Paths**:
   - Use relative paths when referencing tutorial files
   - Use explicit output directories

## Content Guidelines

1. **Narrative Context**: Maintain Amira's story consistently across tutorials
2. **Progressive Complexity**: Each tutorial should build on previous ones
3. **Fair Witness Principles**: Apply proper context to all examples
4. **Error Handling**: Include guidance for common errors
5. **Security Emphasis**: Emphasize security best practices
6. **Link Strategy**: Link to previous/next tutorials and relevant concepts

## Testing Requirements

All tutorials should be:

1. **Verified**: Code snippets should be tested to work correctly
2. **Self-contained**: Users should be able to follow each tutorial independently
3. **Robust**: Account for common user errors
4. **Current**: Kept updated as the underlying technology evolves

## Review Checklist

Before finalizing a tutorial, ensure:

- [ ] All code snippets follow variable naming and syntax conventions
- [ ] Commands work when run sequentially
- [ ] Outputs match what users will actually see
- [ ] Links to other documents are correct
- [ ] Story consistency is maintained
- [ ] Fair witness principles are applied
- [ ] Scripts run without errors
- [ ] Style is consistent with other tutorials