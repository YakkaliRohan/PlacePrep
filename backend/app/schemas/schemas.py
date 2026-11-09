from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, EmailStr

# --- Auth & User Schemas ---
class UserSignup(BaseModel):
    name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class GuestLogin(BaseModel):
    name: Optional[str] = "Guest Explorer"

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    college: Optional[str] = None
    degree: Optional[str] = None
    graduation_year: Optional[str] = None
    avatar: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    college: str
    degree: str
    graduation_year: str
    avatar: str
    is_guest: bool
    tests_taken: int
    questions_solved: int
    streak: int
    total_accuracy: float
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class TokenData(BaseModel):
    user_id: Optional[int] = None
    email: Optional[str] = None


# --- Question Schemas ---
class QuestionResponse(BaseModel):
    id: int
    topic: str
    question_text: str
    options: List[str]
    # Note: correct_answer is excluded during test taking, included only for review
    correct_answer: Optional[int] = None
    explanation: Optional[str] = None
    concept: str
    difficulty: str
    tags: List[str]
    company_tags: List[str]

    class Config:
        from_attributes = True


# --- Test & Exam Schemas ---
class AnswerSubmission(BaseModel):
    question_id: int
    selected_option: Optional[int] = None # None if skipped / unattempted
    time_spent_seconds: Optional[int] = 0

class TestSubmission(BaseModel):
    test_title: str
    test_type: str # practice, company, daily, sprint, drill, marathon
    answers: List[AnswerSubmission]
    total_time_seconds: int

class DetailedAnswerResult(BaseModel):
    question_id: int
    question_text: str
    options: List[str]
    selected_option: Optional[int]
    correct_answer: int
    is_correct: bool
    explanation: str
    concept: str
    difficulty: str

class TestResultResponse(BaseModel):
    attempt_id: int
    test_title: str
    test_type: str
    total_questions: int
    correct_count: int
    incorrect_count: int
    unattempted_count: int
    score: float
    accuracy: float
    time_taken_seconds: int
    section_breakdown: Dict[str, Any]
    answers_summary: List[DetailedAnswerResult]
    created_at: datetime

class TestAttemptHistoryResponse(BaseModel):
    id: int
    test_title: str
    test_type: str
    score: float
    total_questions: int
    correct_count: int
    accuracy: float
    time_taken_seconds: int
    created_at: datetime

    class Config:
        from_attributes = True


# --- Leaderboard Schemas ---
class LeaderboardUser(BaseModel):
    rank: int
    user_id: int
    name: str
    avatar: str
    tests_taken: int
    questions_solved: int
    streak: int
    accuracy: float

class LeaderboardResponse(BaseModel):
    total_participants: int
    top_performers: List[LeaderboardUser]
    user_rank: Optional[LeaderboardUser] = None


# --- Admin & Analytics Schemas ---
class AdminStatsResponse(BaseModel):
    total_users: int
    total_tests_taken: int
    total_questions_in_bank: int
    average_accuracy: float
    topic_distribution: Dict[str, int]
    difficulty_distribution: Dict[str, int]

class FeedbackCreate(BaseModel):
    name: Optional[str] = ""
    email: Optional[str] = ""
    rating: int = 5
    category: str = "general"
    message: str

class FeedbackResponse(BaseModel):
    id: int
    name: str
    email: str
    rating: int
    category: str
    message: str
    created_at: datetime

    class Config:
        from_attributes = True
