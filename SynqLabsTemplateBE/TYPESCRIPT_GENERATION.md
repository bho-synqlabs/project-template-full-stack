# 🔧 TypeScript Type Generation Setup (.NET 9)

This document explains how to automatically generate TypeScript types from your ASP.NET Core 9 backend API for use in your frontend application.

## 📋 Overview

The setup uses **NSwag** to automatically generate TypeScript interfaces and API client classes from your OpenAPI/Swagger specification. This ensures type safety between your backend and frontend while eliminating manual type maintenance.

### .NET 9 Compatibility

This configuration is specifically set up for **.NET 9** projects with:
- `"runtime": "Net90"` in `nswag.json`
- `$(NSwagExe_Net90)` MSBuild reference
- Compatible NSwag version that supports .NET 9

## 🚀 Quick Start

### 1. **First-Time Setup**

Choose one of these configuration methods:

#### Option A: Environment Variables (Recommended)
```bash
# Set environment variables for your setup
export FRONTEND_TYPES_PATH="../my-frontend/src/types/api-types.ts"
export FRONTEND_REPO_PATH="../my-frontend"
```

#### Option B: Local Configuration File
```bash
# Copy example config and customize
cp src/Web.Api/nswag.local.json.example src/Web.Api/nswag.local.json
# Edit nswag.local.json with your specific output path
```

#### Option C: Direct Path Parameters
No setup needed - specify paths when running scripts.

### 2. **Generation Methods**

#### **Automatic Generation**
Types are automatically generated during development builds:

```bash
# Navigate to the backend directory
cd src/Web.Api

# Build the project (this will auto-generate types to local folder)
dotnet build --configuration Debug
```

#### **Manual Generation with Flexible Paths**

**Using Environment Variables:**
```bash
# If you set FRONTEND_TYPES_PATH, it will use that automatically
./generate-types.sh

# PowerShell
./generate-types.ps1
```

**Specifying Custom Output Path:**
```bash
# Generate directly to your frontend
./generate-types.sh "../my-frontend/src/types/api-types.ts"

# PowerShell
./generate-types.ps1 -OutputPath "../my-frontend/src/types/api-types.ts"
```

**With Automatic Frontend Copying:**
```bash
# Set FRONTEND_REPO_PATH and use copy flag
./generate-types.sh "" "Development" "" true

# PowerShell
./generate-types.ps1 -CopyToFrontend
```

## 📁 Generated Output

The generated file (`api-types.ts`) contains:

- **TypeScript Interfaces**: For all your request/response DTOs
- **API Client Classes**: Type-safe methods for calling your endpoints
- **Enums**: For any enums defined in your backend
- **Error Types**: For handling API exceptions

### Example Generated Types:
```typescript
// User interfaces
export interface UserResponse {
    id: string;
    email: string;
    createdAt: Date;
}

export interface CreateTodoCommand {
    title: string;
    description?: string;
    priority: Priority;
}

// API Client
export class TodosClient {
    constructor(baseUrl?: string, http?: { fetch(url: RequestInfo, init?: RequestInit): Promise<Response> }) { }
    
    getTodos(): Promise<TodoResponse[]>;
    createTodo(command: CreateTodoCommand): Promise<TodoResponse>;
    // ... other endpoints
}
```

## 🔄 Integration with Frontend

### Flexible Configuration Options

#### **Option 1: Environment Variables** ⭐ *Recommended*
Set up once, works everywhere:

```bash
# In your shell profile (.bashrc, .zshrc, etc.)
export FRONTEND_TYPES_PATH="/absolute/path/to/frontend/src/types/api-types.ts"
export FRONTEND_REPO_PATH="/absolute/path/to/frontend"

# Or use relative paths
export FRONTEND_TYPES_PATH="../my-frontend/src/types/api-types.ts"
export FRONTEND_REPO_PATH="../my-frontend"
```

#### **Option 2: Local Configuration File**
Create `src/Web.Api/nswag.local.json` (gitignored):

```bash
# Copy the example
cp src/Web.Api/nswag.local.json.example src/Web.Api/nswag.local.json
```

Then edit the output path in `nswag.local.json`:
```json
{
  "codeGenerators": {
    "openApiToTypeScriptClient": {
      "output": "../../../../my-frontend/src/types/api-types.ts"
    }
  }
}
```

#### **Option 3: Script Parameters**
Pass paths directly to generation scripts:

```bash
# Bash
./generate-types.sh "/path/to/frontend/src/types/api-types.ts"

# PowerShell  
./generate-types.ps1 -OutputPath "/path/to/frontend/src/types/api-types.ts"
```

#### **Option 4: Frontend Build Integration**
Add to your frontend's `package.json`:

```json
{
  "scripts": {
    "generate-types": "cd ../backend && ./generate-types.sh \"$(pwd)/src/types/api-types.ts\"",
    "prebuild": "npm run generate-types"
  }
}
```

#### **Option 5: Team Configuration**
For teams, document the setup in your project README:

```bash
# Team members run once:
export FRONTEND_TYPES_PATH="$(pwd)/../frontend/src/types/api-types.ts"

# Then just use:
cd backend && ./generate-types.sh
```

## ⚙️ Configuration

### NSwag Configuration (`nswag.json`)

Key configuration options you can customize:

```json
{
  "codeGenerators": {
    "openApiToTypeScriptClient": {
      "className": "ApiClient",           // Generated client class name
      "generateClientClasses": true,      // Generate API client methods
      "generateDtoTypes": true,           // Generate TypeScript interfaces
      "typeStyle": "Class",               // "Class" or "Interface"
      "dateTimeType": "Date",             // How to handle DateTime
      "nullValue": "Undefined",           // How to handle null values
      "output": "../../generated/api-types.ts"  // Output file path
    }
  }
}
```

### Build Integration

The TypeScript generation is configured to run automatically during Debug builds via MSBuild target in `Web.Api.csproj`:

```xml
<Target Name="NSwag" AfterTargets="PostBuildEvent" Condition="'$(Configuration)' == 'Debug'">
  <Exec Command="$(NSwagExe_Net90) run nswag.json" ContinueOnError="true" />
</Target>
```

## 🔧 Troubleshooting

### Common Issues:

1. **"NSwag command not found"**
   ```bash
   # Install NSwag CLI globally
   dotnet tool install -g NSwag.ConsoleCore
   ```

2. **Build errors prevent generation**
   - Ensure your backend builds successfully
   - Check for any compilation errors in your DTOs/endpoints

3. **Generated file is empty**
   - Verify your API is properly documented with OpenAPI attributes
   - Check that endpoints are discoverable by Swagger

4. **Path not found errors**
   - Ensure the output directory exists
   - Check file permissions for the target directory

5. **.NET 9 Version Issues**
   - Ensure you have .NET 9 SDK installed: `dotnet --version`
   - Verify `nswag.json` has `"runtime": "Net90"`
   - Check MSBuild target uses `$(NSwagExe_Net90)` not `$(NSwagExe_Net80)`

6. **Path Configuration Issues**
   - Check if your environment variables are set: `echo $FRONTEND_TYPES_PATH`
   - Verify `nswag.local.json` exists and has correct output path
   - Use absolute paths if relative paths aren't working
   - Check file permissions for the target directory

7. **jq Command Not Found (Bash Script)**
   ```bash
   # Install jq for JSON manipulation
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

### Debugging Generation:

Enable verbose output in `nswag.json`:
```json
{
  "documentGenerator": {
    "aspNetCoreToOpenApi": {
      "verbose": true
    }
  }
}
```

## 📦 Frontend Usage Examples

### Using Generated Types:
```typescript
import { TodosClient, CreateTodoCommand, TodoResponse, Priority } from './types/api-types';

// Initialize client
const apiClient = new TodosClient('https://localhost:5001');

// Create a new todo with type safety
const newTodo: CreateTodoCommand = {
  title: 'Learn TypeScript generation',
  description: 'Set up automatic type generation from backend',
  priority: Priority.High
};

// Call API with full type safety
const createdTodo: TodoResponse = await apiClient.createTodo(newTodo);
```

### Using with React/Angular/Vue:
```typescript
// React Hook example
const useTodos = () => {
  const [todos, setTodos] = useState<TodoResponse[]>([]);
  
  useEffect(() => {
    const fetchTodos = async () => {
      const apiClient = new TodosClient();
      const todoList = await apiClient.getTodos();
      setTodos(todoList);
    };
    
    fetchTodos();
  }, []);
  
  return todos;
};
```

## 🔄 Updating Types

Whenever you modify your backend DTOs or add new endpoints:

1. **Automatic**: Types will regenerate on next Debug build
2. **Manual**: Run `./generate-types.sh` or `./generate-types.ps1`
3. **Frontend**: Copy/sync the updated types to your frontend

## 📈 Benefits

- ✅ **Type Safety**: Catch API integration errors at compile time
- ✅ **Auto-Completion**: Full IntelliSense support in your IDE
- ✅ **Consistency**: Types always match your backend contracts
- ✅ **Productivity**: Eliminate manual type definitions
- ✅ **Refactoring**: Safe renames and changes across frontend/backend

## 🔗 Additional Resources

- [NSwag Documentation](https://github.com/RicoSuter/NSwag)
- [OpenAPI Specification](https://swagger.io/specification/)
- [ASP.NET Core OpenAPI](https://docs.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger)
