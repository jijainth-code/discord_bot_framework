import os
import sys
import importlib.util
import discord
from discord.ext import commands
from dotenv import load_dotenv
import asyncio

# Load environment variables
load_dotenv()

# Bot setup
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

class WorkerFunctionManager:
    def __init__(self):
        self.functions = {}
        self.worker_functions_path = "worker_functions"
        
    def discover_functions(self):
        """Dynamically discover and load worker functions"""
        if not os.path.exists(self.worker_functions_path):
            print(f"Warning: {self.worker_functions_path} directory not found")
            return
            
        for folder_name in os.listdir(self.worker_functions_path):
            folder_path = os.path.join(self.worker_functions_path, folder_name)
            
            if os.path.isdir(folder_path):
                # Look for the main function file
                function_file = os.path.join(folder_path, f"{folder_name}_function.py")
                
                if os.path.exists(function_file):
                    try:
                        # Import the module dynamically
                        spec = importlib.util.spec_from_file_location(
                            f"{folder_name}_function", function_file
                        )
                        module = importlib.util.module_from_spec(spec)
                        spec.loader.exec_module(module)
                        
                        # Store the function and its metadata
                        if hasattr(module, 'FUNCTION_INFO'):
                            self.functions[folder_name] = {
                                'module': module,
                                'info': module.FUNCTION_INFO
                            }
                            print(f"Loaded function: {folder_name}")
                        else:
                            print(f"Warning: {function_file} missing FUNCTION_INFO")
                            
                    except Exception as e:
                        print(f"Error loading {function_file}: {e}")
                        



# Initialize function manager
function_manager = WorkerFunctionManager()

@bot.event
async def on_ready():
    """Called when the bot is ready"""
    print(f'{bot.user} has connected to Discord!')
    
    # Discover worker functions
    function_manager.discover_functions()
    
    # Sync slash commands
    try:
        synced = await bot.tree.sync()
        print(f"Synced {len(synced)} command(s)")
    except Exception as e:
        print(f"Failed to sync commands: {e}")

class FunctionSelectView(discord.ui.View):
    def __init__(self, function_manager):
        super().__init__(timeout=300)  # 5 minute timeout
        self.function_manager = function_manager
        
        # Create buttons for each function
        for i, (name, data) in enumerate(function_manager.functions.items(), 1):
            if i <= 5:  # Discord limits to 5 buttons per row
                info = data['info']
                button = discord.ui.Button(
                    label=f"{i}. {info['name'].title()}",
                    custom_id=f"function_{name}",
                    style=discord.ButtonStyle.primary,
                    emoji="🔧"
                )
                button.callback = self.create_function_callback(name)
                self.add_item(button)
    
    def create_function_callback(self, function_name):
        async def function_callback(interaction):
            await self.handle_function_selection(interaction, function_name)
        return function_callback
    
    async def handle_function_selection(self, interaction, function_name):
        """Handle when a user selects a function - completely generic"""
        try:
            function_data = self.function_manager.functions[function_name]
            
            # Check if the function has a get_modal method
            if hasattr(function_data['module'], 'get_modal'):
                # Let the worker function create its own modal
                modal = function_data['module'].get_modal(self.function_manager, function_name)
                await interaction.response.send_modal(modal)
            else:
                # Fallback for functions without modal interface
                embed = discord.Embed(
                    title=f"🚧 {function_data['info']['name'].title()} Function",
                    description=f"Function '{function_name}' doesn't implement parameter collection interface.",
                    color=0xffaa00
                )
                await interaction.response.send_message(embed=embed, ephemeral=True)
                
        except Exception as e:
            embed = discord.Embed(
                title="❌ Error",
                description=f"Error handling function selection: {str(e)}",
                color=0xff0000
            )
            await interaction.response.send_message(embed=embed, ephemeral=True)

@bot.tree.command(name="bot", description="Access all available worker functions")
async def bot_command(interaction: discord.Interaction):
    """
    Main bot command - shows all available functions with interactive buttons
    """
    if not function_manager.functions:
        embed = discord.Embed(
            title="❌ No Functions Available",
            description="No worker functions found in the worker_functions directory.",
            color=0xff0000
        )
        await interaction.response.send_message(embed=embed)
        return
    
    # Create embed with function list
    functions_text = "**Available Worker Functions:**\n\n"
    for i, (name, data) in enumerate(function_manager.functions.items(), 1):
        info = data['info']
        functions_text += f"**{i}. {info['name'].title()}**\n"
        functions_text += f"   📝 {info['description']}\n"
        
        if info.get('parameters'):
            params = ", ".join([f"{p['name']} ({p['type']})" for p in info['parameters']])
            functions_text += f"   📊 Parameters: {params}\n"
        functions_text += "\n"
    
    functions_text += "👆 **Click a button below to use a function!**"
    
    embed = discord.Embed(
        title="🤖 Discord Bot Framework",
        description=functions_text,
        color=0x0099ff
    )
    embed.set_footer(text="Functions are loaded dynamically from worker_functions/")
    
    # Create interactive view with buttons
    view = FunctionSelectView(function_manager)
    
    await interaction.response.send_message(embed=embed, view=view)

@bot.event
async def on_command_error(ctx, error):
    """Handle command errors"""
    if isinstance(error, commands.CommandNotFound):
        return
    print(f"An error occurred: {error}")

if __name__ == "__main__":
    # Get Discord token from environment
    token = os.getenv('DISCORD_TOKEN')
    
    if not token:
        print("❌ Error: DISCORD_TOKEN not found in environment variables!")
        print("Please create a .env file with your Discord bot token:")
        print("DISCORD_TOKEN=your_discord_bot_token_here")
        sys.exit(1)
    
    try:
        print("🚀 Starting Discord Bot Framework...")
        bot.run(token)
    except discord.LoginFailure:
        print("❌ Error: Invalid Discord token!")
    except Exception as e:
        print(f"❌ Error starting bot: {e}") 