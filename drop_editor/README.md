# Shaiya Monster Drop Editor

This is a simple tool to edit the monster drops for a Shaiya private server. It allows you to view monsters and add, edit, or delete their drop "Grades" and corresponding drop rates by directly interacting with the game database.

## Prerequisites

1.  **Python 3**: Make sure you have Python 3 installed.
2.  **ODBC Driver for SQL Server**: This tool uses the `pyodbc` library, which requires a Microsoft ODBC driver to connect to your SQL Server database. You can download it from the [Microsoft website](https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server).

## Setup

1.  **Install Dependencies**:
    Open a terminal or command prompt in this directory (`drop_editor`) and run the following command to install the required Python library:
    ```
    pip install -r requirements.txt
    ```

2.  **Configure Database Connection**:
    Open the `config.ini` file in a text editor. You need to fill in the details for your SQL Server database connection:
    ```ini
    [database]
    server = YOUR_SERVER_ADDRESS
    database = PS_GameDefs
    username = YOUR_USERNAME
    password = YOUR_PASSWORD
    ```
    - `server`: The IP address or hostname of your database server (e.g., `localhost`, `192.168.1.100`).
    - `database`: The name of the game definitions database. It's typically `PS_GameDefs`.
    - `username`: Your SQL Server username.
    - `password`: Your SQL Server password.

## How to Run

Once the setup is complete, you can run the application by executing the `main.py` script:
```
python main.py
```

A window should appear that lists the monsters from your database. You can then select a monster to view and edit its drops.
