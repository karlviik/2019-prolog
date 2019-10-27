from pyswip import Prolog
from pathlib import Path
import datetime
import itertools
import requests
import random
import time

# ------------------ CONSTANTS ISH --------------------------------
# Token: https://developer.lufthansa.com/io-docs
ACCESS_TOKEN = "j35ygz9fk25rh4hqa6buja5v"
PROLOG_FILE = "prax06.pl"
# Tallinn(TLL), Helsinki(HEL), LondonHeathrow(LHR), Stockholm(ARN), FrankfurtGer(FRA), Warsaw(WAW), Paris(CDG), Oslo(OSL), Iceland(ISL), Latvia(RIX)
AIRPORTS = {"TLL": "estonia", "HEL": "finland", "LHR": "uk", "ARN": "sweden", "FRA": "germany", "CDG": "france",
            "OSL": "norway", "KEF": "iceland", "MAD": "spain", "FCO": "italy", "CPH": "denmark"}
AIRPORT_COMBINATIONS = itertools.combinations(list(AIRPORTS.keys()), 2)
TODAY = datetime.date.today().strftime("%Y-%m-%d")
FACTS_PATH = Path(f"./{TODAY}")


def build_facts():
    if FACTS_PATH.is_file():
        return
    else:
        f = FACTS_PATH.open("x")
        ip = requests.get("https://jsonip.com/").json()["ip"]
        lines = []
        for combination in AIRPORT_COMBINATIONS:
            time.sleep(0.4)
            for i in range(2):
                x = requests.get(
                    f"https://api.lufthansa.com/v1/operations/schedules/{combination[(0 + i) % 2]}/{combination[(1 + i) % 2]}/{TODAY}?limit=6",
                    "",
                    headers={
                        "Accept": "application/json",
                        "Authorization": f"Bearer {ACCESS_TOKEN}",
                        "X-Originating-IP": f"{ip}"
                    }
                )
                if x.status_code != 200:
                    continue
                flights = x.json()["ScheduleResource"]["Schedule"]
                if type(flights) is not list:
                    flights = [flights]
                for flight in flights:
                    if type(flight["Flight"]) is not list:
                        start = flight["Flight"]["Departure"]["ScheduledTimeLocal"]["DateTime"]
                        end = flight["Flight"]["Arrival"]["ScheduledTimeLocal"]["DateTime"]
                    else:
                        start = flight["Flight"][0]["Departure"]["ScheduledTimeLocal"]["DateTime"]
                        end = flight["Flight"][-1]["Arrival"]["ScheduledTimeLocal"]["DateTime"]
                    start = datetime.datetime.strptime(start, "%Y-%m-%dT%H:%M")
                    end = datetime.datetime.strptime(end, "%Y-%m-%dT%H:%M")
                    line = f"lennukiga({AIRPORTS.get(combination[(0 + i) % 2])},{AIRPORTS.get(combination[(1 + i) % 2])},{random.randint(10, 1000)},time({start.hour},{start.minute},0),time({end.hour},{end.minute},0)).\n"
                    lines.append(line)
        f.writelines(lines)
        f.close()


class Prologer:

    def __init__(self):
        self.prolog = Prolog()
        build_facts()
        self.prolog.consult(f"{PROLOG_FILE}")
        self.prolog.consult(f"{TODAY}")
        # self.prolog.query(f"consult(a{TODAY}.pl).")

    def query(self, query):
        return self.prolog.query(query)


if __name__ == '__main__':
    queries = ["odavaim_reis(uk, estonia, X, Y).", "lyhim_reis(uk, estonia, X, Y)."]
    prologger = Prologer()
    # prologger.query(f"consult({TODAY}.pl).")
    print("starting queries")
    for query in queries:
        for solution in prologger.query(query):
            print(solution["X"], solution["Y"])
