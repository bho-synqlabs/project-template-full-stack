# 🚀 Quick Setup Guide - TypeScript Generation

**Choose your preferred setup method based on your team's needs:**

## 🌟 Method 1: Environment Variables (Recommended)

**Perfect for**: Individual developers, flexible setups

1. **Set environment variables** (add to your shell profile):
   ```bash
   export FRONTEND_TYPES_PATH="../my-frontend/src/types/api-types.ts"
   export FRONTEND_REPO_PATH="../my-frontend"
   ```

2. **Generate types**:
   ```bash
   ./generate-types.sh  # Uses environment variables automatically
   ```

## 📁 Method 2: Local Configuration File

**Perfect for**: Different paths per developer, complex setups

1. **Create local config**:
   ```bash
   cp src/Web.Api/nswag.local.json.example src/Web.Api/nswag.local.json
   ```

2. **Edit the output path** in `nswag.local.json`:
   ```json
   "output": "../../../../my-frontend/src/types/api-types.ts"
   ```

3. **Generate types**:
   ```bash
   ./generate-types.sh  # Uses nswag.local.json automatically
   ```

## ⚡ Method 3: Direct Path

**Perfect for**: One-off generation, CI/CD

```bash
./generate-types.sh "/absolute/path/to/frontend/src/types/api-types.ts"
```

## 🔄 Method 4: Frontend Integration

**Perfect for**: Automated workflows

Add to your frontend's `package.json`:
```json
{
  "scripts": {
    "types": "cd ../backend && ./generate-types.sh \"$(pwd)/src/types/api-types.ts\"",
    "dev": "npm run types && next dev"
  }
}
```

## 📋 What Gets Generated

Your backend DTOs become TypeScript interfaces:

```typescript
// From your C# DTOs
export interface TodoResponse {
    id: string;
    title: string;
    description?: string;
    priority: Priority;
    isCompleted: boolean;
    createdAt: Date;
}

export interface CreateTodoCommand {
    title: string;
    description?: string;
    priority: Priority;
}

// Plus API client methods
const todosClient = new TodosClient();
const todos = await todosClient.getTodos();
```

## 🛠️ Files Created

- `nswag.json` - Default configuration (generates to local folder)
- `nswag.local.json.example` - Template for custom paths
- `generate-types.sh` / `generate-types.ps1` - Flexible generation scripts
- `src/Web.Api/.gitignore` - Ignores local configs and temp files

## ✅ Quick Test

```bash
# Test generation
./generate-types.sh

# Check output
ls -la generated/api-types.ts  # Should exist
```

---

**Need help?** Check `TYPESCRIPT_GENERATION.md` for full documentation and troubleshooting.
