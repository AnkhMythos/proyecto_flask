from flask import Flask, render_template, request, g, redirect, url_for
import mysql.connector

template_dir = 'templates'
app = Flask(__name__, template_folder=template_dir)

DATABASE_CONFIG = {
    'user': 'tu_usuario',
    'password': 'tu_contraseña',
    'host': 'tu_host',
    'database': 'tu_base_de_datos'
}

@app.before_request
def connect_to_db():
    if 'db' not in g:
        g.db = mysql.connector.connect(**DATABASE_CONFIG)

@app.teardown_request
def close_db(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()

@app.route('/')
def index():
    cursor = g.db.cursor()
    cursor.execute("SELECT * FROM usuarios")
    usuarios = cursor.fetchall()
    return render_template('index.html', usuarios=usuarios)

@app.route('/agregar', methods=['GET', 'POST'])
def agregar():
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        pais = request.form['pais']
        asunto = request.form['asunto']
        es_medico = request.form['es_medico']

        cursor = g.db.cursor()
        cursor.execute("INSERT INTO usuarios (nombre, apellido, pais, asunto, es_medico) VALUES (%s, %s, %s, %s, %s)", (nombre, apellido, pais, asunto, es_medico))
        g.db.commit()

        return redirect(url_for('index'))

    return render_template('agregar.html')

@app.route('/editar/<int:id>', methods=['GET', 'POST'])
def editar(id):
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        pais = request.form['pais']
        asunto = request.form['asunto']
        es_medico = request.form['es_medico']

        cursor = g.db.cursor()
        cursor.execute("UPDATE usuarios SET nombre=%s, apellido=%s, pais=%s, asunto=%s, es_medico=%s WHERE id=%s", (nombre, apellido, pais, asunto, es_medico, id))
        g.db.commit()

        return redirect(url_for('index'))

    cursor = g.db.cursor()
    cursor.execute("SELECT * FROM usuarios WHERE id=%s", (id,))
    usuario = cursor.fetchone()
    return render_template('editar.html', usuario=usuario)

@app.route('/eliminar/<int:id>')
def eliminar(id):
    cursor = g.db.cursor()
    cursor.execute("DELETE FROM usuarios WHERE id=%s", (id,))
    g.db.commit()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)