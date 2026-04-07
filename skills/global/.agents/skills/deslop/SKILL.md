---
name: deslop
description: Use after AI-generated code to remove slop (excess comments/defensive checks). Not for general refactors.
---

# Remove AI code slop

Check the diff against main, and remove all AI generated slop introduced in this branch.

This includes:
- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file

Report at the end with only a 1-3 sentence summary of what you changed

## Example

Before (AI slop):
```typescript
// Check if the user exists before proceeding
if (user !== null && user !== undefined) {
  try {
    // Attempt to update the user's profile
    await updateProfile(user.id, data);
  } catch (error) {
    // Handle any errors that might occur
    console.error('Error updating profile:', error);
    throw error;
  }
}
```

After (deslopped):
```typescript
if (user) {
  await updateProfile(user.id, data);
}
```
