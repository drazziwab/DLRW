# automator/gui.py

import tkinter as tk
from tkinter import ttk, messagebox

def GUI(settings=None):
    root = tk.Tk()
    root.title("Daily Login Automator")
    root.geometry("700x500")
    root.resizable(False, False)

    notebook = ttk.Notebook(root)
    notebook.pack(fill="both", expand=True, padx=10, pady=10)

    # --- Tab 1: Settings Viewer ---
    tab_settings = ttk.Frame(notebook)
    notebook.add(tab_settings, text="Settings")

    settings_text = tk.Text(tab_settings, wrap="word", height=20)
    settings_text.pack(fill="both", expand=True, padx=10, pady=10)

    settings_text.insert("1.0", f"{settings}" if settings else "No settings loaded.")
    settings_text.configure(state="disabled")

    # --- Tab 2: Automation ---
    tab_actions = ttk.Frame(notebook)
    notebook.add(tab_actions, text="Automation")

    def start_automation():
        messagebox.showinfo("Automation", "Automation started!")

    def stop_automation():
        messagebox.showinfo("Automation", "Automation stopped.")

    btn_start = ttk.Button(tab_actions, text="Start Automation", command=start_automation)
    btn_start.pack(pady=20)

    btn_stop = ttk.Button(tab_actions, text="Stop Automation", command=stop_automation)
    btn_stop.pack(pady=10)

    # --- Tab 3: Logs ---
    tab_logs = ttk.Frame(notebook)
    notebook.add(tab_logs, text="Logs")

    log_output = tk.Text(tab_logs, wrap="word", height=15)
    log_output.pack(fill="both", expand=True, padx=10, pady=10)
    log_output.insert("1.0", "Log viewer placeholder.\n")
    log_output.configure(state="disabled")

    root.mainloop()

