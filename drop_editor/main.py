import tkinter as tk
from tkinter import ttk, messagebox
import database as db

class DropDialog(tk.Toplevel):
    def __init__(self, parent, title=None, initial_data=None):
        super().__init__(parent)
        self.transient(parent)
        if title:
            self.title(title)

        self.parent = parent
        self.result = None

        self.body = ttk.Frame(self)
        self.initial_data = initial_data
        self.create_widgets()
        self.body.pack(padx=5, pady=5)

        self.grab_set()
        self.protocol("WM_DELETE_WINDOW", self.cancel)
        self.geometry("+%d+%d" % (parent.winfo_rootx()+50,
                                  parent.winfo_rooty()+50))
        self.wait_window(self)

    def create_widgets(self):
        ttk.Label(self.body, text="Item Order:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.order_entry = ttk.Entry(self.body)
        self.order_entry.grid(row=0, column=1, sticky=tk.EW, pady=2)

        ttk.Label(self.body, text="Grade:").grid(row=1, column=0, sticky=tk.W, pady=2)
        self.grade_entry = ttk.Entry(self.body)
        self.grade_entry.grid(row=1, column=1, sticky=tk.EW, pady=2)

        ttk.Label(self.body, text="Drop Rate:").grid(row=2, column=0, sticky=tk.W, pady=2)
        self.rate_entry = ttk.Entry(self.body)
        self.rate_entry.grid(row=2, column=1, sticky=tk.EW, pady=2)

        if self.initial_data:
            self.order_entry.insert(0, self.initial_data.get('ItemOrder', ''))
            self.grade_entry.insert(0, self.initial_data.get('Grade', ''))
            self.rate_entry.insert(0, self.initial_data.get('DropRate', ''))

        button_frame = ttk.Frame(self)
        ok_button = ttk.Button(button_frame, text="OK", command=self.ok)
        ok_button.pack(side=tk.LEFT, padx=5, pady=5)
        cancel_button = ttk.Button(button_frame, text="Cancel", command=self.cancel)
        cancel_button.pack(side=tk.LEFT, padx=5, pady=5)
        button_frame.pack()

    def ok(self, event=None):
        try:
            order = int(self.order_entry.get())
            grade = int(self.grade_entry.get())
            rate = int(self.rate_entry.get())
        except ValueError:
            messagebox.showerror("Invalid Input", "Please enter valid integers for all fields.")
            return

        self.result = {'ItemOrder': order, 'Grade': grade, 'DropRate': rate}
        self.destroy()

    def cancel(self, event=None):
        self.destroy()


class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.master.title("Shaiya Monster Drop Editor")
        self.master.geometry("800x600")
        self.pack(fill=tk.BOTH, expand=True)

        self.selected_mob_id = None
        self.conn = None
        self.monsters = {}

        self.create_widgets()
        self.connect_to_db()

    def connect_to_db(self):
        self.conn = db.get_db_connection()
        if not self.conn or isinstance(self.conn, Exception):
            messagebox.showerror(
                "Database Connection Failed",
                "Could not connect to the database. Please check your config.ini.\n\n"
                f"Error: {self.conn}"
            )
            self.master.destroy()
            return

        self.monsters = db.get_monsters(self.conn)
        if self.monsters is None:
            messagebox.showerror("Failed to Load Data", "Could not fetch monster list from the database.")
            self.master.destroy()
            return

        self.populate_monster_list()

    def create_widgets(self):
        self.paned_window = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        self.paned_window.pack(fill=tk.BOTH, expand=True)

        self.left_frame = ttk.Frame(self.paned_window, width=200)
        self.right_frame = ttk.Frame(self.paned_window)
        self.paned_window.add(self.left_frame, weight=1)
        self.paned_window.add(self.right_frame, weight=3)

        monster_list_label = ttk.Label(self.left_frame, text="Monsters")
        monster_list_label.pack(pady=5)
        self.monster_listbox = tk.Listbox(self.left_frame)
        self.monster_listbox.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        self.monster_listbox.bind('<<ListboxSelect>>', self.on_monster_select)

        self.selected_monster_label = ttk.Label(self.right_frame, text="Select a monster to see its drops", font=("Arial", 12))
        self.selected_monster_label.pack(pady=5)

        columns = ('row_id', 'item_order', 'grade', 'drop_rate')
        self.drop_tree = ttk.Treeview(self.right_frame, columns=columns, show='headings')
        self.drop_tree.heading('row_id', text='RowID')
        self.drop_tree.heading('item_order', text='Order')
        self.drop_tree.heading('grade', text='Grade')
        self.drop_tree.heading('drop_rate', text='Drop Rate')
        self.drop_tree.column('row_id', width=50)
        self.drop_tree.column('item_order', width=50)
        self.drop_tree.column('grade', width=80)
        self.drop_tree.column('drop_rate', width=100)
        self.drop_tree.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        button_frame = ttk.Frame(self.right_frame)
        button_frame.pack(fill=tk.X, pady=5)
        add_button = ttk.Button(button_frame, text="Add Drop", command=self.add_drop)
        add_button.pack(side=tk.LEFT, padx=5)
        edit_button = ttk.Button(button_frame, text="Edit Selected", command=self.edit_drop)
        edit_button.pack(side=tk.LEFT, padx=5)
        delete_button = ttk.Button(button_frame, text="Delete Selected", command=self.delete_drop)
        delete_button.pack(side=tk.LEFT, padx=5)

    def populate_monster_list(self):
        self.monster_listbox.delete(0, tk.END)
        for mob_id, mob_name in self.monsters.items():
            self.monster_listbox.insert(tk.END, f"{mob_id}: {mob_name}")

    def on_monster_select(self, event):
        selection_indices = self.monster_listbox.curselection()
        if not selection_indices: return
        selected_item = self.monster_listbox.get(selection_indices[0])
        self.selected_mob_id = int(selected_item.split(':')[0])
        self.selected_monster_label.config(text=f"Drops for: {self.monsters[self.selected_mob_id]} (ID: {self.selected_mob_id})")
        self.refresh_drop_list()

    def refresh_drop_list(self):
        for i in self.drop_tree.get_children(): self.drop_tree.delete(i)
        if self.selected_mob_id:
            drops = db.get_monster_drops(self.conn, self.selected_mob_id)
            if drops is not None:
                for drop in drops:
                    self.drop_tree.insert('', tk.END, values=(drop['RowID'], drop['ItemOrder'], drop['Grade'], drop['DropRate']))

    def add_drop(self):
        if not self.selected_mob_id:
            messagebox.showwarning("No Monster Selected", "Please select a monster before adding a drop.")
            return

        dialog = DropDialog(self, title="Add New Drop")
        if dialog.result:
            new_data = dialog.result
            if db.add_monster_drop(self.conn, self.selected_mob_id, new_data['ItemOrder'], new_data['Grade'], new_data['DropRate']):
                self.refresh_drop_list()
            else:
                messagebox.showerror("Database Error", "Failed to add the new drop.")

    def edit_drop(self):
        selected_items = self.drop_tree.selection()
        if not selected_items:
            messagebox.showwarning("No Selection", "Please select a drop to edit.")
            return
        if len(selected_items) > 1:
            messagebox.showwarning("Multiple Selections", "Please select only one drop to edit.")
            return

        item_id = selected_items[0]
        selected_drop_values = self.drop_tree.item(item_id)['values']
        initial_data = {'RowID': selected_drop_values[0], 'ItemOrder': selected_drop_values[1], 'Grade': selected_drop_values[2], 'DropRate': selected_drop_values[3]}

        dialog = DropDialog(self, title="Edit Drop", initial_data=initial_data)
        if dialog.result:
            updated_data = dialog.result
            if db.update_monster_drop(self.conn, initial_data['RowID'], updated_data['ItemOrder'], updated_data['Grade'], updated_data['DropRate']):
                self.refresh_drop_list()
            else:
                messagebox.showerror("Database Error", "Failed to update the drop.")

    def delete_drop(self):
        selected_items = self.drop_tree.selection()
        if not selected_items:
            messagebox.showwarning("No Selection", "Please select a drop to delete.")
            return
        if not messagebox.askyesno("Confirm Delete", "Are you sure you want to delete the selected drop(s)?"):
            return

        success = True
        for item_id in selected_items:
            row_id_to_delete = self.drop_tree.item(item_id)['values'][0]
            if not db.delete_monster_drop(self.conn, row_id_to_delete):
                success = False

        if not success:
            messagebox.showerror("Database Error", "Failed to delete one or more drops.")

        self.refresh_drop_list()

if __name__ == "__main__":
    root = tk.Tk()
    app = Application(master=root)
    # The app will handle its own lifecycle, including closing on DB error
    # so we don't need a "try" block here.
    app.mainloop()
