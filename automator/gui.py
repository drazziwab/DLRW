import tkinter as tk
from tkinter import ttk, messagebox
import os
import threading
import queue

def find_game_executables(search_paths, update_status, progress, result_queue):
    game_exes = []
    extensions = (".exe",)
    exclude_dirs = ["Windows", "ProgramData", "AppData", "Intel", "NVIDIA", "Temp", "Microsoft", "Common Files"]

    all_folders = []
    for base_path in search_paths:
        if os.path.exists(base_path):
            for root, dirs, files in os.walk(base_path):
                if any(skip in root for skip in exclude_dirs):
                    continue
                all_folders.append(root)

    total = len(all_folders)
    for i, root in enumerate(all_folders):
        update_status(f"Scanning: {root}")
        progress(i + 1, total)
        for file in os.listdir(root):
            if file.lower().endswith(extensions):
                game_exes.append(os.path.join(root, file))

    result_queue.put(game_exes)

def GUI(settings=None):
    root = tk.Tk()
    root.title("Daily Login Automator")
    root.geometry("900x700")
    root.resizable(False, False)

    notebook = ttk.Notebook(root)
    notebook.pack(fill="both", expand=True, padx=10, pady=10)

    # --- Tab 1: Settings Viewer ---
    tab_settings = ttk.Frame(notebook)
    notebook.add(tab_settings, text="Settings")

    settings_text = tk.Text(tab_settings, wrap="word", height=15)
    settings_text.pack(fill="both", expand=True, padx=10, pady=10)
    settings_text.insert("1.0", f"{settings}" if settings else "No settings loaded.")
    settings_text.configure(state="disabled")

    # --- Tab 2: Automation ---
    tab_actions = ttk.Frame(notebook)
    notebook.add(tab_actions, text="Automation")

    ttk.Button(tab_actions, text="Start Automation", command=lambda: messagebox.showinfo("Automation", "Started")).pack(pady=10)
    ttk.Button(tab_actions, text="Stop Automation", command=lambda: messagebox.showinfo("Automation", "Stopped")).pack(pady=10)

    # --- Tab 3: Logs ---
    tab_logs = ttk.Frame(notebook)
    notebook.add(tab_logs, text="Logs")

    log_output = tk.Text(tab_logs, wrap="word", height=15)
    log_output.pack(fill="both", expand=True, padx=10, pady=10)
    log_output.insert("1.0", "Log viewer placeholder.\n")
    log_output.configure(state="disabled")

    # --- Tab 4: Game Scanner ---
    tab_scan = ttk.Frame(notebook)
    notebook.add(tab_scan, text="Game Scanner")

    scan_output = tk.Text(tab_scan, wrap="word", height=20)
    scan_output.pack(fill="both", expand=True, padx=10, pady=10)

    status_label = ttk.Label(tab_scan, text="Status: Ready")
    status_label.pack(pady=5)

    progress_var = tk.DoubleVar()
    progress_bar = ttk.Progressbar(tab_scan, variable=progress_var, maximum=100)
    progress_bar.pack(fill="x", padx=10, pady=5)

    def update_status(text):
        status_label.config(text=text)

    def update_progress(current, total):
        pct = (current / total) * 100 if total else 0
        progress_var.set(pct)
        root.update_idletasks()

    def start_game_scan():
        scan_output.configure(state="normal")
        scan_output.delete("1.0", tk.END)
        scan_output.configure(state="disabled")
        update_status("Preparing scan...")
        progress_var.set(0)

        custom_paths = settings["search_paths"] if settings and "search_paths" in settings else []
        drives = [f"{d}:\\" for d in "CDEFGHIJKLMNOPQRSTUVWXYZ" if os.path.exists(f"{d}:\\")]

        game_paths = set(custom_paths)
        for drive in drives:
            game_paths.add(os.path.join(drive, "Program Files"))
            game_paths.add(os.path.join(drive, "Program Files (x86)"))
            game_paths.add(os.path.join(drive, "Games"))
            game_paths.add(os.path.join(drive, "Program Files (x86)", "Steam", "steamapps", "common"))

        result_queue = queue.Queue()

        def thread_worker():
            try:
                found_games = find_game_executables(game_paths, update_status, update_progress, result_queue)
            except Exception as e:
                result_queue.put(f"Error: {e}")

        def check_result():
            if result_queue.empty():
                root.after(500, check_result)
                return
            result = result_queue.get()
            scan_output.configure(state="normal")
            if isinstance(result, str):
                scan_output.insert("1.0", result)
            else:
                for path in result:
                    scan_output.insert(tk.END, path + "\n")
            scan_output.configure(state="disabled")
            update_status("Status: Done.")

        threading.Thread(target=thread_worker, daemon=True).start()
        check_result()

    ttk.Button(tab_scan, text="Scan for Games", command=start_game_scan).pack(pady=5)

    root.mainloop()
