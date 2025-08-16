import configparser
import pyodbc

def get_db_connection():
    """
    Establishes a connection to the database using credentials from config.ini.
    """
    config = configparser.ConfigParser()
    # Ensure the path is correct when running from main.py
    config.read('drop_editor/config.ini')

    db_config = config['database']

    server = db_config.get('server')
    # The user provided schema uses PS_GameDefs
    database = db_config.get('database', 'PS_GameDefs')
    username = db_config.get('username')
    password = db_config.get('password')

    conn_str = (
        f'DRIVER={{ODBC Driver 17 for SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'UID={username};'
        f'PWD={password};'
    )

    try:
        conn = pyodbc.connect(conn_str)
        return conn
    except pyodbc.Error as ex:
        # Return the exception to be handled in the GUI
        return ex

def get_monsters(conn):
    """
    Fetches all monsters from the Mobs table.
    Returns a dictionary of {MobID: MobName}.
    """
    monsters = {}
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT MobID, MobName FROM Mobs ORDER BY MobName")
        for row in cursor.fetchall():
            monsters[row.MobID] = row.MobName
        return monsters
    except pyodbc.Error as ex:
        print(f"Failed to get monsters: {ex}")
        return None

def get_monster_drops(conn, mob_id):
    """
    Fetches all drops for a specific monster.
    Returns a list of drop dictionaries.
    """
    drops = []
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT RowID, MobID, ItemOrder, Grade, DropRate FROM MobItems WHERE MobID = ? ORDER BY ItemOrder", mob_id)
        for row in cursor.fetchall():
            drops.append({
                'RowID': row.RowID,
                'MobID': row.MobID,
                'ItemOrder': row.ItemOrder,
                'Grade': row.Grade,
                'DropRate': row.DropRate
            })
        return drops
    except pyodbc.Error as ex:
        print(f"Failed to get monster drops: {ex}")
        return None

def add_monster_drop(conn, mob_id, item_order, grade, drop_rate):
    """
    Adds a new drop to the MobItems table.
    """
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO MobItems (MobID, ItemOrder, Grade, DropRate) VALUES (?, ?, ?, ?)",
            mob_id, item_order, grade, drop_rate
        )
        conn.commit()
        return True
    except pyodbc.Error as ex:
        print(f"Failed to add monster drop: {ex}")
        conn.rollback()
        return False

def update_monster_drop(conn, row_id, item_order, grade, drop_rate):
    """
    Updates an existing drop in the MobItems table.
    """
    try:
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE MobItems SET ItemOrder = ?, Grade = ?, DropRate = ? WHERE RowID = ?",
            item_order, grade, drop_rate, row_id
        )
        conn.commit()
        return True
    except pyodbc.Error as ex:
        print(f"Failed to update monster drop: {ex}")
        conn.rollback()
        return False

def delete_monster_drop(conn, row_id):
    """
    Deletes a drop from the MobItems table.
    """
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM MobItems WHERE RowID = ?", row_id)
        conn.commit()
        return True
    except pyodbc.Error as ex:
        print(f"Failed to delete monster drop: {ex}")
        conn.rollback()
        return False
