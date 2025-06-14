from flask import Flask, jsonify
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)
CORS(app)

# Basic team logo mapping
TEAM_LOGOS = {
    "Dublin": "https://upload.wikimedia.org/wikipedia/en/4/42/Dublin_GAA_crest.svg",
    "Kerry": "https://upload.wikimedia.org/wikipedia/en/f/fb/Kerry_GAA_crest.svg",
    "Mayo": "https://upload.wikimedia.org/wikipedia/en/6/6f/Mayo_GAA_crest.svg",
    "Armagh": "https://upload.wikimedia.org/wikipedia/en/e/e3/Armagh_GAA_crest.svg",
    "Antrim": "https://upload.wikimedia.org/wikipedia/en/b/bf/Antrim_GAA_crest.svg",
    "Galway": "https://upload.wikimedia.org/wikipedia/en/2/2d/Galway_GAA_crest.svg",
    "Tipperary": "https://upload.wikimedia.org/wikipedia/en/3/30/Tipperary_GAA_crest.svg",
    # Add more teams here as needed
}

def detect_sport_from_competition(name: str) -> str:
    name = name.lower()
    if "hurl" in name:
        return "Hurling"
    elif "camogie" in name:
        return "Camogie"
    else:
        return "Football"

def get_logo(team_name):
    return TEAM_LOGOS.get(team_name, "")

def scrape_fixtures():
    url = "https://www.gaa.ie/fixtures-results/"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')

    fixtures = []

    for card in soup.select(".fixtures-card"):
        teams = card.select_one(".fixture__teams")
        if not teams:
            continue

        team_names = [t.text.strip() for t in teams.select(".fixture__team-name")]
        if len(team_names) != 2:
            continue

        home, away = team_names
        date_el = card.select_one(".fixture__date")
        time_el = card.select_one(".fixture__time")
        venue_el = card.select_one(".fixture__venue")
        comp_el = card.select_one(".fixture__competition")

        date = date_el.text.strip() if date_el else "TBC"
        time = time_el.text.strip() if time_el else "TBC"
        venue = venue_el.text.strip() if venue_el else "TBC"
        competition = comp_el.text.strip() if comp_el else ""

        fixture = {
            "homeTeam": home,
            "awayTeam": away,
            "homeScore": 0,
            "awayScore": 0,
            "status": "Upcoming",
            "sport": detect_sport_from_competition(competition),
            "date": date,
            "time": time,
            "venue": venue,
            "homeLogo": get_logo(home),
            "awayLogo": get_logo(away)
        }

        fixtures.append(fixture)

    # Add IDs
    for i, f in enumerate(fixtures):
        f["id"] = i + 1

    return fixtures

@app.route('/matches')
def get_matches():
    return jsonify(scrape_fixtures())

@app.route('/standings')
def get_standings():
    return jsonify([
        {"id": "dublin", "team": "Dublin", "played": 3, "won": 2, "drawn": 1, "lost": 0, "points": 7},
        {"id": "kerry", "team": "Kerry", "played": 3, "won": 2, "drawn": 0, "lost": 1, "points": 6},
        {"id": "mayo", "team": "Mayo", "played": 3, "won": 1, "drawn": 1, "lost": 1, "points": 4},
        {"id": "armagh", "team": "Armagh", "played": 3, "won": 0, "drawn": 0, "lost": 3, "points": 0}
    ])

if __name__ == '__main__':
    app.run(debug=True)
