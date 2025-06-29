import discord
from discord.ext import commands

async def execute_greet(interaction, name: str):
    """
    Greet someone with a hello message
    
    Args:
        interaction: Discord interaction object
        name: String to greet
    
    Returns:
        str: Result message
    """
    try:
        # Create the greeting message
        greeting_message = f"Hello {name}!"
        
        # Create an embed for better formatting
        embed = discord.Embed(
            title="🌟 Greeting Message",
            description=f"**{greeting_message}**",
            color=0x00ff88
        )
        embed.add_field(name="Greeted", value=name, inline=True)
        embed.add_field(name="Message", value=greeting_message, inline=True)
        embed.set_footer(text="Powered by Discord Bot Framework")
        
        await interaction.followup.send(embed=embed)
        return f"Successfully greeted: {name}"
        
    except Exception as e:
        error_embed = discord.Embed(
            title="Error",
            description=f"An error occurred: {str(e)}",
            color=0xff0000
        )
        await interaction.followup.send(embed=error_embed)
        return f"Error: {str(e)}"

class GreetFunctionModal(discord.ui.Modal):
    def __init__(self, function_manager, function_name):
        super().__init__(title="Greet Someone")
        self.function_manager = function_manager
        self.function_name = function_name
        
        self.name_input = discord.ui.TextInput(
            label="Name or Text to Greet",
            placeholder="Enter the name or text you want to greet...",
            required=True,
            max_length=100
        )
        
        self.add_item(self.name_input)
    
    async def on_submit(self, interaction):
        await interaction.response.defer()
        
        try:
            # Get the input string
            name_to_greet = self.name_input.value.strip()
            
            if not name_to_greet:
                embed = discord.Embed(
                    title="❌ Invalid Input",
                    description="Please enter a name or text to greet.",
                    color=0xff0000
                )
                await interaction.followup.send(embed=embed, ephemeral=True)
                return
            
            # Execute the greet function
            await execute_greet(interaction, name_to_greet)
            
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
    return GreetFunctionModal(function_manager, function_name)

# Function metadata for the bot to discover
FUNCTION_INFO = {
    "name": "greet",
    "description": "Say hello to someone with a personalized greeting",
    "parameters": [
        {"name": "name", "type": "string", "description": "Name or text to greet"}
    ]
} 