from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import random

app = Flask(__name__)
CORS(app)

@app.route('/matches')
def get_matches():
    today = datetime.today()

    mock_data = [
        {
            "id": 1,
            "homeTeam": "Dublin",
            "awayTeam": "Kerry",
            "homeScore": random.randint(0, 3),
            "awayScore": random.randint(0, 3),
            "status": "Full Time",
            "sport": "Football",
            "date": (today - timedelta(days=1)).strftime("%Y-%m-%d"),
            "time": "19:30",
            "venue": "Croke Park",
            "homeLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/4/42/Dublin_GAA_crest.svg/1200px-Dublin_GAA_crest.svg.png",
            "awayLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/f/fb/Kerry_GAA_crest.svg/1200px-Kerry_GAA_crest.svg.png"
        },
        {
            "id": 2,
            "homeTeam": "Antrim",
            "awayTeam": "Armagh",
            "homeScore": random.randint(0, 3),
            "awayScore": random.randint(0, 3),
            "status": "Live",
            "sport": "Hurling",
            "date": today.strftime("%Y-%m-%d"),
            "time": "18:00",
            "venue": "Casement Park",
            "homeLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/Antrim_GAA_crest.svg/1200px-Antrim_GAA_crest.svg.png",
            "awayLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/e/e3/Armagh_GAA_crest.svg/1200px-Armagh_GAA_crest.svg.png"
        },
        {
            "id": 3,
            "homeTeam": "Galway",
            "awayTeam": "Tipperary",
            "homeScore": 0,
            "awayScore": 0,
            "status": "Upcoming",
            "sport": "Camogie",
            "date": (today + timedelta(days=1)).strftime("%Y-%m-%d"),
            "time": "14:00",
            "venue": "Pearse Stadium",
            "homeLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/2/2d/Galway_GAA_crest.svg/1200px-Galway_GAA_crest.svg.png",
            "awayLogo": "https://upload.wikimedia.org/wikipedia/en/thumb/3/30/Tipperary_GAA_crest.svg/1200px-Tipperary_GAA_crest.svg.png"
        }
    ]

    return jsonify(mock_data)

if __name__ == '__main__':
    app.run(debug=True)
