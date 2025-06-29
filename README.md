# 🤖 Discord Bot Framework

An extensible, modular Discord bot framework that allows contributors to easily add new functions through worker modules. Built with Python and Docker for easy deployment and development.

## 🌟 What This Bot Does

This framework creates a Discord bot that:
- **Dynamically discovers** worker functions from the `worker_functions/` directory
- **Lists available functions** via the `/bot` slash command  
- **Provides interactive UI** with buttons and modals for function execution
- **Supports easy contribution** - just add a new worker function and submit a PR!

### Current Functions
- **Add** - Adds two numbers together
- **Greet** - Greets a user with a personalized message

*Want to add more? See the [Contributing](#-contributing) section!*

## 🏗️ Architecture

```
discord_bot_framework/
├── src/
│   └── main.py              # Core bot logic & function discovery
├── worker_functions/        # 🎯 Add your functions here!
│   ├── add/
│   │   └── add_function.py
│   └── greet/
│       └── greet_function.py
├── docker/                  # Docker configuration
├── scripts/                 # Utility scripts
└── requirements.txt         # Python dependencies
```

### How It Works

1. **Discovery**: Bot scans `worker_functions/` for modules
2. **Registration**: Each valid worker function gets registered
3. **User Interaction**: `/bot` command shows numbered list of functions
4. **Execution**: User clicks button → modal opens → function executes → results displayed

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Discord Bot Token ([Create one here](https://discord.com/developers/applications))
- Docker (optional, for containerized deployment)

### Local Development
1. Clone the repository
2. Create `.env` file with your Discord token:
   ```env
   DISCORD_TOKEN=your_discord_bot_token_here
   ```
3. Run the setup and start script:
   ```bash
   ./run.sh
   ```

### Docker Deployment
```bash
# Build and run
./docker-run.sh

# Stop
./docker_stop.sh

# View logs
./docker-run.sh logs
```

## 🤝 Contributing

We welcome contributions! Here's how to add a new worker function:

### 1. Create Function Structure
```bash
mkdir worker_functions/your_function_name
cd worker_functions/your_function_name
touch your_function_name_function.py
```

### 2. Implement Your Function
Your function file must include:

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

### 3. Test Your Function
```bash
# Test locally
./run.sh

# Test with Docker
./docker-run.sh build
./docker-run.sh run
```

### 4. Submit Pull Request
1. Fork the repository
2. Create a feature branch: `git checkout -b add-my-function`
3. Commit your changes: `git commit -am 'Add my awesome function'`
4. Push to branch: `git push origin add-my-function`
5. Create Pull Request with description of your function

## 📝 Function Guidelines

### Naming Convention
- Folder: `worker_functions/function_name/`
- File: `function_name_function.py`
- Functions: `execute_function_name()`, `get_modal()`
- Class: `FunctionNameModal`

### Required Components
- `FUNCTION_INFO` dictionary with name, description, and parameters
- `get_modal()` function that returns a Discord Modal
- `execute_function_name()` async function with your logic
- Discord Modal class for parameter collection

### Best Practices
- Keep functions focused and single-purpose
- Validate user input in your modal
- Use Discord embeds for rich responses
- Handle errors gracefully
- Add docstrings to your functions
- Test thoroughly before submitting PR

### Example Functions Ideas
- **Calculator functions** (multiply, divide, power, etc.)
- **Text utilities** (reverse text, word count, etc.)  
- **Random generators** (dice roll, pick random, etc.)
- **Converters** (temperature, currency, units, etc.)
- **Fun commands** (jokes, facts, quotes, etc.)
- **Utility functions** (QR codes, shortened URLs, etc.)

## 🔧 Development

### Project Structure
```
├── src/main.py                    # Core bot with WorkerFunctionManager
├── worker_functions/              # All bot functions live here
│   ├── add/add_function.py       # Example: Addition function
│   └── greet/greet_function.py   # Example: Greeting function
├── docker/                        # Docker configuration files
├── scripts/                       # Utility shell scripts
├── requirements.txt               # Python dependencies
└── README.md                     # This file
```

### Core Bot Components
- **WorkerFunctionManager**: Discovers and loads worker functions
- **Dynamic Command Registration**: Automatically registers `/bot` command
- **Interactive UI**: Buttons and modals for user interaction
- **Error Handling**: Graceful error handling and user feedback

### Environment Variables
```env
DISCORD_TOKEN=your_discord_bot_token_here
```

### Docker Support
- **Production**: `./docker-run.sh` 
- **Development**: `docker-compose -f docker/docker-compose.dev.yml up`
- **Cleanup**: `./docker-run.sh cleanup`

## 🐛 Troubleshooting

### Bot Not Starting
- Check Discord token in `.env` file
- Verify Python 3.9+ is installed
- Check console for error messages

### Function Not Loading
- Ensure file follows naming convention
- Check for required components (`FUNCTION_INFO`, `get_modal()`, `execute_*()`)
- Verify no syntax errors in function file
- Check console logs for loading errors

### Docker Issues
- Ensure Docker is running
- Check if `.env` file exists
- Try rebuilding: `./docker-run.sh build`

## 📊 Contributing Stats

![Contributors](https://img.shields.io/github/contributors/jijainth-code/discord_bot_framework)
![Pull Requests](https://img.shields.io/github/issues-pr/jijainth-code/discord_bot_framework)
![Issues](https://img.shields.io/github/issues/jijainth-code/discord_bot_framework)

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built with [discord.py](https://discordpy.readthedocs.io/)
- Containerized with Docker
- Thanks to all contributors who help expand the bot's functionality!

---

**Ready to contribute?** Start by exploring the existing functions in `worker_functions/` and then add your own! 🚀 