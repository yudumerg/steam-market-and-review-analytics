"""Rule-based complaint detection for Steam player reviews.

Three generations of labelling rules live here so the notebook can compare them:

- v1: the original first-match keyword rules (kept only for comparison)
- v3: word-boundary regexes, negation handling, clause splitting,
      multi-label output and a sentiment check for ambiguous words

A category is assigned when a review *complains* about it, even inside an
otherwise positive review ("Great game but full of bugs" -> Bug).
"""

import re

CATEGORIES = ["Bug", "Crash", "Update", "Price", "Server", "Lag", "DLC", "Cheater"]


# ---------------------------------------------------------------------------
# v1 - original rules (substring match, first match wins, single label)
# ---------------------------------------------------------------------------

V1_KEYWORDS = [
    ("Bug", ["bug", "bugs", "buggy", "glitch", "glitches", "broken", "issue", "issues",
             "problem", "problems", "not working", "doesn't work", "unplayable", "fix this"]),
    ("Crash", ["crash", "crashes", "crashing", "crashed", "freeze", "freezing", "frozen"]),
    ("Update", ["update", "patch", "patched", "after update", "new update", "latest update"]),
    ("Price", ["price", "expensive", "too expensive", "cost", "overpriced", "not worth"]),
    ("Server", ["server", "servers", "connection", "disconnect", "disconnected", "matchmaking"]),
    ("Lag", ["lag", "laggy", "latency", "stutter", "fps drop", "performance"]),
    ("DLC", ["dlc", "expansion", "expansions", "paywall"]),
    ("Cheater", ["hack", "hacker", "hackers", "cheat", "cheater", "cheaters"]),
]


def complaints_v1(text):
    """Original logic: lowercase substring search, the first matching category wins."""
    text = str(text).lower()

    for category, keywords in V1_KEYWORDS:
        if any(keyword in text for keyword in keywords):
            return [category]

    return []


# ---------------------------------------------------------------------------
# v3 - improved rules
# ---------------------------------------------------------------------------

# Words that are negative on their own: a match counts as a complaint.
STRONG = {
    "Bug": [r"bugs?", r"buggy", r"buggiest", r"glitch(es|ed|y)?", r"unplayable", r"not working",
            r"(doesn'?t|does not|won'?t|will not|didn'?t|did not) (even )?work", r"game[- ]breaking"],
    "Crash": [r"crash(es|ed|ing)?", r"freez(e|es|ing)", r"froze", r"frozen", r"black screen"],
    "Update": [],
    "Price": [r"overpriced", r"over ?priced", r"not worth (it|the money|the price|\$?\d+)",
              r"waste of money", r"wait (for|until) (a |the )?(steam )?sale", r"rip ?off", r"cash ?grab"],
    "Server": [r"disconnect(s|ed|ing)?", r"desync", r"dsync", r"empty servers?", r"dead servers?",
               r"no servers?"],
    "Lag": [r"lag(s|gy|ging)?", r"stutter(s|ing)?", r"fps drops?", r"low fps",
            r"poorly optimi[sz]ed", r"bad(ly)? optimi[sz]ed",
            r"optimi[sz]ation (issues?|problems?|needed)", r"runs? like (crap|shit|garbage)"],
    "DLC": [r"pay[- ]to[- ]win", r"p2w", r"microtransactions?", r"loot ?box(es)?", r"paywall"],
    "Cheater": [r"hack(s|er|ers|ing)", r"hax", r"cheat(er|ers|ing)", r"aimbot", r"smurfs?"],
}

# Words that can be neutral or positive ("best update ever", "great price"):
# a match only counts when its clause is negative.
WEAK = {
    "Bug": [r"broken", r"issues?", r"problems?"],
    "Crash": [],
    "Update": [r"updates?", r"patch(es|ed)?", r"hotfix(es)?"],
    "Price": [r"price[sd]?", r"full price", r"expensive", r"refund(ed)?", r"\$\d+"],
    "Server": [r"servers?", r"matchmaking", r"connection", r"online"],
    "Lag": [r"performance", r"fps", r"loading( times?)?", r"optimi[sz](ation|ed)"],
    "DLC": [r"dlcs?", r"expansions?", r"season pass", r"recharge"],
    "Cheater": [r"cheats?"],
}


def _compile(patterns_by_category):
    """One case-insensitive regex per category. \\b = whole words only."""
    return {
        category: re.compile(r"\b(" + "|".join(patterns) + r")\b", re.IGNORECASE)
        for category, patterns in patterns_by_category.items()
        if patterns
    }


STRONG_RE = _compile(STRONG)
WEAK_RE = _compile(WEAK)

# Phrases that look like complaints but are not.
EXCLUDE_RE = re.compile(
    r"hack (and|n|&) slash|no (bugs?|glitch(es)?|crash(es|ing)?|lag)\b", re.IGNORECASE
)

# A negation word up to two words before the keyword: "no lag", "never had any crashes".
NEGATION_RE = re.compile(
    r"\b(no|not|never|without|zero|none|barely|hardly|any|n'?t)\s+(\w+\s+){0,2}$", re.IGNORECASE
)

# Split into sentences and into clauses around contrast words, so the
# "but ..." part of "Great game but the servers are terrible" is judged alone.
CLAUSE_SPLIT_RE = re.compile(
    r"(?<=[.!?])|\n+|\b(?:but|however|although|though|tho|except)\b", re.IGNORECASE
)

NEGATIVE_CLAUSE = -0.05  # VADER compound score at or below this = negative clause


def split_clauses(text):
    return [part.strip() for part in CLAUSE_SPLIT_RE.split(str(text)) if part and part.strip()]


def _first_unnegated_match(regex, clause):
    for match in regex.finditer(clause):
        if not NEGATION_RE.search(clause[: match.start()]):
            return match
    return None


def complaints_v3(text, sentiment_score):
    """Return the sorted list of complaint categories in a review.

    sentiment_score: function clause -> float in [-1, 1] (e.g. VADER compound).
    """
    found = set()

    for clause in split_clauses(text):
        clause = EXCLUDE_RE.sub(" ", clause)

        for category in CATEGORIES:
            if category in found:
                continue

            strong = STRONG_RE.get(category)
            if strong and _first_unnegated_match(strong, clause):
                found.add(category)
                continue

            weak = WEAK_RE.get(category)
            if weak and _first_unnegated_match(weak, clause):
                if sentiment_score(clause) <= NEGATIVE_CLAUSE:
                    found.add(category)

    return sorted(found)
