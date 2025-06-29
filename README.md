# 🤖 Discord Bot Framework

An extensible Discord bot framework that allows you to easily add new functions through worker modules.

## 🌟 What This Bot Does

- **Dynamically discovers** worker functions from the `worker_functions/` directory
- **Lists available functions** via the `/bot` slash command  
- **Provides interactive UI** with buttons and modals for function execution

## 🚀 Quick Start

1. Clone the repository
2. Create `.env` file with your Discord token:
   ```env
   DISCORD_TOKEN=your_discord_bot_token_here
   ```
3. Run: `./run.sh` or `./docker-run.sh`

## 📝 Adding Worker Functions

### 1. Create Function Structure
```bash
mkdir worker_functions/your_function_name
cd worker_functions/your_function_name
touch your_function_name_function.py
```

### 2. Function Template
```python
import discord

# Function metadata (required)
FUNCTION_INFO = {
    "name": "Your Function Name",
    "description": "Brief description of what your function does",
    "parameters": ["param1", "param2"]  # List of parameter names
}

# Modal class for parameter collection (required)
class YourFunctionModal(discord.ui.Modal, title='Your Function Parameters'):
    def __init__(self):
        super().__init__()
        
    # Add input fields
    param1 = discord.ui.TextInput(
        label='Parameter 1',
        placeholder='Enter value for parameter 1...',
        required=True,
        max_length=100
    )
    
    param2 = discord.ui.TextInput(
        label='Parameter 2', 
        placeholder='Enter value for parameter 2...',
        required=True,
        max_length=100
    )
    
    async def on_submit(self, interaction: discord.Interaction):
        # Get values
        param1_value = self.param1.value
        param2_value = self.param2.value
        
        # Execute your function logic
        result = await execute_your_function_name(param1_value, param2_value)
        
        # Create response embed
        embed = discord.Embed(
            title="Your Function Result",
            description=f"Result: {result}",
            color=0x00ff00
        )
        
        await interaction.response.send_message(embed=embed, ephemeral=True)

# Function to return modal (required)
def get_modal():
    return YourFunctionModal()

# Main function logic (required)
async def execute_your_function_name(param1, param2):
    """
    Your function implementation here.
    
    Args:
        param1: First parameter
        param2: Second parameter
        
    Returns:
        Result of your function
    """
    # Your logic here
    result = f"Processed {param1} and {param2}"
    return result
```

### 3. Required Components

Each worker function must have:
- `FUNCTION_INFO` dictionary with name, description, and parameters
- `get_modal()` function that returns a Discord Modal
- `execute_function_name()` async function with your logic
- Discord Modal class for parameter collection

### 4. Naming Convention
- Folder: `worker_functions/function_name/`
- File: `function_name_function.py`
- Functions: `execute_function_name()`, `get_modal()`
- Class: `FunctionNameModal`

### 5. Test Your Function
```bash
# Test locally
./run.sh

# Test with Docker
./docker-run.sh
```

That's it! Your function will automatically appear in the `/bot` command list after restart.

## 📁 Project Structure
```
discord_bot_framework/
├── src/main.py              # Core bot logic
├── worker_functions/        # 🎯 Add your functions here!
│   ├── add/
│   │   └── add_function.py
│   └── greet/
│       └── greet_function.py
├── docker/                  # Docker configuration
├── scripts/                 # Utility scripts
└── requirements.txt         # Python dependencies
``` 