# Contributing to Discord Bot Framework

Thank you for your interest in contributing to the Discord Bot Framework! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### Types of Contributions
- **Worker Functions**: Add new bot functionality
- **Bug Fixes**: Fix issues in existing code
- **Documentation**: Improve README, comments, or guides
- **Feature Enhancements**: Improve existing functionality
- **Code Quality**: Refactoring, testing, optimization

## 🚀 Getting Started

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/discord_bot_framework.git
cd discord_bot_framework
```

### 2. Set Up Development Environment
```bash
# Create .env file
echo "DISCORD_TOKEN=your_test_bot_token_here" > .env

# Test local setup
./run.sh

# Test Docker setup
./docker-run.sh build
```

### 3. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

## 📝 Adding Worker Functions

### Step-by-Step Guide

#### 1. Plan Your Function
- What will it do? (Keep it focused and single-purpose)
- What parameters does it need?
- What will the output look like?

#### 2. Create Function Structure
```bash
mkdir worker_functions/your_function
cd worker_functions/your_function
touch your_function_function.py
```

#### 3. Function Template
Use this template as a starting point:

```python
import discord

# Function metadata (required)
FUNCTION_INFO = {
    "name": "Your Function Name",
    "description": "Brief description of what your function does",
    "parameters": ["param1", "param2"]  # List of parameter names
}

class YourFunctionModal(discord.ui.Modal, title='Your Function Title'):
    def __init__(self):
        super().__init__()
        
    # Add your input fields here
    param1 = discord.ui.TextInput(
        label='Parameter 1',
        placeholder='Enter value...',
        required=True,
        max_length=100
    )
    
    async def on_submit(self, interaction: discord.Interaction):
        try:
            # Get parameter values
            param1_value = self.param1.value
            
            # Execute your function
            result = await execute_your_function(param1_value)
            
            # Create success embed
            embed = discord.Embed(
                title="Function Result",
                description=f"Result: {result}",
                color=0x00ff00
            )
            
            await interaction.response.send_message(embed=embed, ephemeral=True)
            
        except Exception as e:
            # Error handling
            error_embed = discord.Embed(
                title="Error",
                description=f"An error occurred: {str(e)}",
                color=0xff0000
            )
            await interaction.response.send_message(embed=error_embed, ephemeral=True)

def get_modal():
    """Return the modal for this function (required)"""
    return YourFunctionModal()

async def execute_your_function(param1):
    """
    Main function logic (required)
    
    Args:
        param1: Description of parameter
        
    Returns:
        Result of your function
    """
    # Your logic here
    result = f"Processed: {param1}"
    return result
```

#### 4. Function Guidelines

**Required Components:**
- `FUNCTION_INFO` dictionary
- `get_modal()` function
- `execute_*()` async function  
- Discord Modal class

**Best Practices:**
- Validate input parameters
- Handle errors gracefully
- Use descriptive parameter names
- Add helpful placeholders
- Keep functions focused
- Add docstrings

**Input Validation Examples:**
```python
# Validate numbers
try:
    number = float(user_input)
except ValueError:
    raise ValueError("Please enter a valid number")

# Validate text length
if len(text) > 100:
    raise ValueError("Text must be 100 characters or less")

# Validate choices
if choice not in ['option1', 'option2', 'option3']:
    raise ValueError("Please select a valid option")
```

### 5. Testing Your Function

#### Local Testing
```bash
# Start bot locally
./run.sh

# Check console for "Loaded function: your_function"
# Test /bot command in Discord
# Test your function through the UI
```

#### Docker Testing
```bash
# Build and test in Docker
./docker-run.sh build
./docker-run.sh run

# Check logs
./docker-run.sh logs
```

#### Validation Checklist
- [ ] Function loads without errors
- [ ] Appears in `/bot` command list
- [ ] Modal opens when button clicked
- [ ] Parameters are validated properly
- [ ] Results display correctly
- [ ] Error messages are helpful
- [ ] Function works in both local and Docker environments

## 🔧 Code Quality

### Style Guidelines
- Follow PEP 8 Python style guide
- Use descriptive variable names
- Add comments for complex logic
- Include docstrings for functions
- Keep functions focused and small

### Error Handling
```python
# Good error handling
try:
    result = risky_operation()
    return result
except SpecificException as e:
    # Log the error
    print(f"Error in function: {e}")
    # Return user-friendly message
    raise ValueError("Something went wrong. Please try again.")
```

### Discord Best Practices
```python
# Use embeds for rich responses
embed = discord.Embed(
    title="Result",
    description="Your result here",
    color=0x00ff00  # Green for success
)

# Use ephemeral messages for user-specific responses
await interaction.response.send_message(embed=embed, ephemeral=True)

# Validate input limits
text_input = discord.ui.TextInput(
    label='Input',
    max_length=100,  # Set reasonable limits
    required=True
)
```

## 📋 Pull Request Process

### 1. Before Submitting
- [ ] Test your changes locally
- [ ] Test with Docker
- [ ] Verify function follows naming conventions
- [ ] Check that all required components are present
- [ ] Ensure error handling is implemented

### 2. PR Description Template
```markdown
## Description
Brief description of what this PR adds/fixes.

## Type of Change
- [ ] New worker function
- [ ] Bug fix
- [ ] Documentation update
- [ ] Feature enhancement

## Function Details (if adding new function)
- **Function Name**: 
- **Description**: 
- **Parameters**: 
- **Example Usage**: 

## Testing
- [ ] Tested locally
- [ ] Tested with Docker
- [ ] Function appears in bot command list
- [ ] All parameters work correctly
- [ ] Error handling works

## Screenshots/Examples
If applicable, add screenshots of your function working.
```

### 3. Review Process
1. Automated checks will run
2. Maintainers will review your code
3. You may be asked to make changes
4. Once approved, your PR will be merged

## 🐛 Bug Reports

### Before Reporting
- Check existing issues first
- Test with latest version
- Verify it's not a configuration issue

### Bug Report Template
```markdown
**Bug Description**
Clear description of the bug.

**Steps to Reproduce**
1. Step 1
2. Step 2
3. See error

**Expected Behavior**
What should happen?

**Environment**
- OS: 
- Python version:
- Docker version (if applicable):

**Logs/Screenshots**
Include relevant error messages or screenshots.
```

## 💡 Feature Requests

### Good Feature Requests
- Solve a real problem
- Fit the bot's purpose
- Are technically feasible
- Include detailed description

### Feature Request Template
```markdown
**Feature Description**
Clear description of the feature.

**Use Case**
Why would this be useful?

**Proposed Implementation**
How might this work?

**Additional Context**
Any other relevant information.
```

## 🤝 Community Guidelines

### Be Respectful
- Use welcoming and inclusive language
- Respect different opinions and experiences
- Focus on constructive feedback

### Be Helpful
- Help other contributors
- Share knowledge and best practices
- Provide helpful code reviews

### Be Patient
- Reviews take time
- Complex changes need thorough testing
- Maintainers are volunteers

## 📚 Resources

### Discord.py Documentation
- [discord.py Docs](https://discordpy.readthedocs.io/)
- [Discord API Reference](https://discord.com/developers/docs)

### Development Tools
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [Docker Documentation](https://docs.docker.com/)
- [Git Guidelines](https://git-scm.com/doc)

### Example Functions
Look at existing functions for inspiration:
- `worker_functions/add/add_function.py` - Basic math operation
- `worker_functions/greet/greet_function.py` - Simple text processing

## ❓ Getting Help

### Where to Ask
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and help
- **Discord**: Real-time chat with maintainers

### What to Include
- Clear description of your issue
- Relevant code snippets
- Error messages
- Environment details

---

Thank you for contributing to the Discord Bot Framework! 🚀 