import requests
from bs4 import BeautifulSoup
import json
import os
import logging
from datetime import datetime, timedelta
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

CACHE_PATH = "cache/matches.json"
CACHE_EXPIRY = 300  # 5 minutes in seconds

def create_session():
    session = requests.Session()
    retry_strategy = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504]
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    return session

def detect_sport(competition_name):
    name = competition_name.lower()
    if "hurl" in name:
        return "Hurling"
    elif "camogie" in name:
        return "Camogie"
    elif "football" in name:
        return "Football"
    else:
        return "Football"  # Default to Football if unknown

def is_cache_valid():
    if not os.path.exists(CACHE_PATH):
        return False
    
    cache_time = os.path.getmtime(CACHE_PATH)
    return (time.time() - cache_time) < CACHE_EXPIRY

def load_cache():
    try:
        with open(CACHE_PATH, "r") as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Error loading cache: {e}")
        return []

def save_cache(data):
    try:
        os.makedirs(os.path.dirname(CACHE_PATH), exist_ok=True)
        with open(CACHE_PATH, "w") as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        logger.error(f"Error saving cache: {e}")

def scrape_fixtures():
    session = create_session()
    url = "https://hoganstand.com/Fixtures/"
    
    try:
        response = session.get(url, timeout=10)
        response.raise_for_status()
    except requests.RequestException as e:
        logger.error(f"Error fetching fixtures: {e}")
        return []

    soup = BeautifulSoup(response.content, 'html.parser')
    fixtures = []

    try:
        date_headers = soup.find_all('h2')
        for header in date_headers:
            date_text = header.get_text(strip=True)
            ul = header.find_next_sibling('ul')
            if not ul:
                continue
                
            for li in ul.find_all('li'):
                try:
                    text = li.get_text(strip=True)
                    parts = text.split(',')
                    if len(parts) < 3:
                        continue
                        
                    teams_part = parts[0].strip()
                    venue = parts[1].strip()
                    time = parts[2].strip()
                    
                    if 'v' not in teams_part:
                        continue
                        
                    home, away = [team.strip() for team in teams_part.split('v')]
                    
                    # Try to detect sport from competition name if available
                    competition = li.find_previous('h3')
                    sport = detect_sport(competition.get_text() if competition else "")

                    fixture = {
                        "id": len(fixtures) + 1,
                        "homeTeam": home,
                        "awayTeam": away,
                        "homeScore": 0,
                        "awayScore": 0,
                        "status": "Upcoming",
                        "sport": sport,
                        "date": date_text,
                        "time": time,
                        "venue": venue,
                        "homeLogo": "",
                        "awayLogo": "",
                        "lastUpdated": datetime.now().isoformat()
                    }
                    fixtures.append(fixture)
                except Exception as e:
                    logger.error(f"Error parsing fixture: {e}")
                    continue
    except Exception as e:
        logger.error(f"Error parsing fixtures page: {e}")
        return []

    return fixtures

def get_live_matches():
    if is_cache_valid():
        logger.info("Returning cached matches")
        return load_cache()

    try:
        logger.info("Fetching fresh matches")
        fixtures = scrape_fixtures()
        if fixtures:
            save_cache(fixtures)
        return fixtures
    except Exception as e:
        logger.error(f"Error in get_live_matches: {e}")
        return load_cache()  # Return cached data if available
