import typer
import json
from automator.gui import GUI

app = typer.Typer()

@app.command()
def gui(config: str = "configs/default_settings.json"):
    with open(config) as f:
        settings = json.load(f)
    GUI(settings)

if __name__ == "__main__":
    app()
