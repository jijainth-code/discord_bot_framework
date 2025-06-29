import discord
from discord.ext import commands

async def execute_add(interaction, num1: float, num2: float):
    """
    Add two numbers and return the result
    
    Args:
        interaction: Discord interaction object
        num1: First number to add
        num2: Second number to add
    
    Returns:
        str: Result message
    """
    try:
        result = num1 + num2
        
        # Create an embed for better formatting
        embed = discord.Embed(
            title="Addition Result",
            description=f"**{num1} + {num2} = {result}**",
            color=0x00ff00
        )
        embed.add_field(name="Operation", value="Addition", inline=True)
        embed.add_field(name="Input 1", value=str(num1), inline=True)
        embed.add_field(name="Input 2", value=str(num2), inline=True)
        
        await interaction.followup.send(embed=embed)
        return f"Successfully calculated: {num1} + {num2} = {result}"
        
    except Exception as e:
        error_embed = discord.Embed(
            title="Error",
            description=f"An error occurred: {str(e)}",
            color=0xff0000
        )
        await interaction.followup.send(embed=error_embed)
        return f"Error: {str(e)}"

class AddFunctionModal(discord.ui.Modal):
    def __init__(self, function_manager, function_name):
        super().__init__(title="Add Two Numbers")
        self.function_manager = function_manager
        self.function_name = function_name
        
        self.num1 = discord.ui.TextInput(
            label="First Number",
            placeholder="Enter the first number...",
            required=True,
            max_length=50
        )
        
        self.num2 = discord.ui.TextInput(
            label="Second Number", 
            placeholder="Enter the second number...",
            required=True,
            max_length=50
        )
        
        self.add_item(self.num1)
        self.add_item(self.num2)
    
    async def on_submit(self, interaction):
        await interaction.response.defer()
        
        try:
            # Convert inputs to float
            number1 = float(self.num1.value)
            number2 = float(self.num2.value)
            
            # Execute the add function
            await execute_add(interaction, number1, number2)
            
        except ValueError:
            embed = discord.Embed(
                title="❌ Invalid Input",
                description="Please enter valid numbers only.",
                color=0xff0000
            )
            await interaction.followup.send(embed=embed, ephemeral=True)
        except Exception as e:
            embed = discord.Embed(
                title="❌ Execution Error",
                description=f"Error executing {self.function_name}: {str(e)}",
                color=0xff0000
            )
            await interaction.followup.send(embed=embed, ephemeral=True)

def get_modal(function_manager, function_name):
    """
    Create and return the modal for this function
    This is called by the main bot to get the parameter collection interface
    """
    return AddFunctionModal(function_manager, function_name)

# Function metadata for the bot to discover
FUNCTION_INFO = {
    "name": "add",
    "description": "Add two numbers together",
    "parameters": [
        {"name": "num1", "type": "float", "description": "First number"},
        {"name": "num2", "type": "float", "description": "Second number"}
    ]
} 