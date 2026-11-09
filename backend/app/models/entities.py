import json
from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True) # None for guest / OAuth
    role = Column(String(20), default="user") # 'user', 'admin'
    
    # Profile & Academic Info
    college = Column(String(150), default="")
    degree = Column(String(100), default="")
    graduation_year = Column(String(20), default="")
    avatar = Column(String(100), default="avatar-default")
    is_guest = Column(Boolean, default=False)
    
    # Cached Stats for fast Leaderboard lookups
    tests_taken = Column(Integer, default=0)
    questions_solved = Column(Integer, default=0)
    streak = Column(Integer, default=0)
    total_accuracy = Column(Float, default=0.0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    test_attempts = relationship("TestAttempt", back_populates="user", cascade="all, delete-orphan")
    bookmarks = relationship("Bookmark", back_populates="user", cascade="all, delete-orphan")


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    topic = Column(String(50), index=True, nullable=False) # aptitude, logical, verbal, coding, data_interp
    question_text = Column(Text, nullable=False)
    _options = Column("options", Text, nullable=False) # JSON encoded list of options
    correct_answer = Column(Integer, nullable=False) # index of correct option (0, 1, 2, 3)
    explanation = Column(Text, default="")
    concept = Column(String(100), index=True, default="")
    difficulty = Column(String(20), index=True, default="Medium") # Easy, Medium, Hard
    _tags = Column("tags", Text, default="[]") # JSON list of tags
    _company_tags = Column("company_tags", Text, default="[]") # JSON list of companies (e.g. TCS, Infosys)

    @property
    def options(self):
        try:
            return json.loads(self._options)
        except Exception:
            return []

    @options.setter
    def options(self, val):
        self._options = json.dumps(val)

    @property
    def tags(self):
        try:
            return json.loads(self._tags)
        except Exception:
            return []

    @tags.setter
    def tags(self, val):
        self._tags = json.dumps(val)

    @property
    def company_tags(self):
        try:
            return json.loads(self._company_tags)
        except Exception:
            return []

    @company_tags.setter
    def company_tags(self, val):
        self._company_tags = json.dumps(val)


class TestAttempt(Base):
    __tablename__ = "test_attempts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    test_title = Column(String(150), nullable=False)
    test_type = Column(String(50), default="practice") # practice, company, daily, sprint, drill, marathon
    
    score = Column(Float, default=0.0)
    total_questions = Column(Integer, default=0)
    correct_count = Column(Integer, default=0)
    incorrect_count = Column(Integer, default=0)
    unattempted_count = Column(Integer, default=0)
    accuracy = Column(Float, default=0.0)
    time_taken_seconds = Column(Integer, default=0)
    
    _section_breakdown = Column("section_breakdown", Text, default="{}") # JSON of accuracy per topic
    _answers_summary = Column("answers_summary", Text, default="[]") # JSON list of detailed question answers
    
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="test_attempts")

    @property
    def section_breakdown(self):
        try:
            return json.loads(self._section_breakdown)
        except Exception:
            return {}

    @section_breakdown.setter
    def section_breakdown(self, val):
        self._section_breakdown = json.dumps(val)

    @property
    def answers_summary(self):
        try:
            return json.loads(self._answers_summary)
        except Exception:
            return []

    @answers_summary.setter
    def answers_summary(self, val):
        self._answers_summary = json.dumps(val)


class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="bookmarks")
    question = relationship("Question")


class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    name = Column(String(100), default="")
    email = Column(String(150), default="")
    rating = Column(Integer, default=5)
    category = Column(String(50), default="general")
    message = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
