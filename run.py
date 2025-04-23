import typer
from automator.gui import GUI

app = typer.Typer()

@app.command()
def gui():
    GUI()

if __name__ == "__main__":
    app()
