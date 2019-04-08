
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def main():
    myhost = os.uname()[1]
<<<<<<< HEAD
    return 'Hello world from containers!!!!!!!!'
=======
    return 'Hello world from the other side!'
>>>>>>> update app to other side

if __name__ == '__main__':
    app.run('0.0.0.0')
