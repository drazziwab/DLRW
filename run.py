import typer
from automator.gui import GUI

app = typer.Typer()

@app.callback()
def main():
    """Main entrypoint for DLRW app CLI."""

@app.command()
def gui(config: str = "configs/default_settings.json"):
    import json
    try:
        with open(config, "r") as f:
            settings = json.load(f)
    except Exception as e:
        settings = None
        print(f"Failed to load settings: {e}")
    GUI(settings)

if __name__ == "__main__":
    app()

