import json
import os
import sys

# Add backend directory to sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import engine, SessionLocal, Base
from app.models.entities import Question, User
from app.services.auth import get_password_hash

def seed_database():
    print("Creating database tables if not existing...")
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # 1. Seed Default Admin User
    admin_email = "admin@placeprep.in"
    existing_admin = db.query(User).filter(User.email == admin_email).first()
    if not existing_admin:
        admin_user = User(
            name="PlacePrep Admin",
            email=admin_email,
            hashed_password=get_password_hash("PlacePrep2026!"),
            role="admin",
            is_guest=False
        )
        db.add(admin_user)
        print("Created default admin user: admin@placeprep.in / PlacePrep2026!")
    else:
        print("Admin user already exists.")

    # 2. Check and Seed Questions
    existing_q_count = db.query(Question).count()
    if existing_q_count > 0:
        print(f"Database already has {existing_q_count} questions. Skipping seed (or delete DB to re-seed).")
        db.close()
        return

    seed_file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "questions_seed.json")
    if not os.path.exists(seed_file):
        seed_file = "/Users/rohanyakkali/Desktop/PlacePrep/questions_seed.json"

    print(f"Loading questions from {seed_file}...")
    with open(seed_file, "r") as f:
        data = json.load(f)

    total_inserted = 0
    for topic, q_list in data.items():
        for item in q_list:
            q = Question(
                topic=topic,
                question_text=item.get("question", "").strip(),
                correct_answer=int(item.get("answer", 0)),
                explanation=item.get("explanation", "").strip(),
                concept=item.get("concept", "").strip(),
                difficulty=item.get("difficulty", "Medium").strip(),
            )
            q.options = item.get("options", [])
            q.tags = item.get("tags", [])
            q.company_tags = item.get("company_tags", [])
            db.add(q)
            total_inserted += 1

    db.commit()
    print(f"Successfully seeded {total_inserted} questions into the database!")
    db.close()

if __name__ == "__main__":
    seed_database()
