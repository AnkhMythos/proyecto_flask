import os
import mysql.connector
from flask import Flask, g, request, redirect, render_template, url_for
from dotenv import load_dotenv

template_dir = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
template_dir = os.path.join(template_dir, 'src', 'templates')

app = Flask(__name__,template_folder=template_dir)

# Cargar variables de entorno desde el archivo .env
load_dotenv()

# Configuración de la base de datos usando variables de entorno
DATABASE_CONFIG ={
    'user': os.getenv('DB_USERNAME'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'port': os.getenv('DB_PORT')
}

# Inicializar la aplicación Flask
app = Flask(__name__)


# Función para obtener la conexión a la base de datos
def get_db(): 
    if 'db' not in g:
        g.db = mysql.connector.connect(**DATABASE_CONFIG)
    return g.db


# Función para cerrar la conexión a la base de datos
@app.teardown_appcontext
def close_db(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# Ruta principal para listar usuarios
@app.route('/')
def index():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios")
    usuarios = cursor.fetchall()
    return render_template('index.html', usuarios=usuarios)

# Ruta para añadir un nuevo usuario
@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        pais = request.form['pais']
        asunto = request.form['asunto']
        es_medico = request.form.get('es_medico', 'off') == 'on'

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO usuarios (nombre, apellido, pais, asunto, es_medico) VALUES (%s, %s, %s, %s, %s)",
            (nombre, apellido, pais, asunto, es_medico)
        )
        conn.commit()
        return redirect(url_for('index'))

    return render_template('add.html')

# Ruta para editar un usuario existente
@app.route('/edit/<int:id>', methods=['GET', 'POST'])
def edit(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        pais = request.form['pais']
        asunto = request.form['asunto']
        es_medico = request.form.get('es_medico', 'off') == 'on'

        cursor.execute(
            "UPDATE usuarios SET nombre=%s, apellido=%s, pais=%s, asunto=%s, es_medico=%s WHERE id=%s",
            (nombre, apellido, pais, asunto, es_medico, id)
        )
        conn.commit()
        return redirect(url_for('index'))

    cursor.execute("SELECT * FROM usuarios WHERE id=%s", (id,))
    usuario = cursor.fetchone()
    return render_template('edit.html', usuario=usuario)

# Ruta para eliminar un usuario
@app.route('/delete/<int:id>', methods=['POST'])
def delete(id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM usuarios WHERE id=%s", (id,))
    conn.commit()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
