ResumeSenseAI Backend

ResumeSenseAI Backend is a FastAPI-based service that analyzes how well a resume matches a job description and generates AI-powered resume improvement suggestions.

The backend combines traditional ATS-style keyword analysis with semantic similarity and local LLM-powered rewriting.

Features

Resume PDF parsing

OCR support for scanned resumes

ATS-style keyword matching

Semantic similarity scoring

Missing keyword detection

AI-powered resume rewrite suggestions

Local LLM inference using Ollama

Fast API responses optimized for mobile clients

Architecture

The backend follows a modular architecture with separated concerns.

resume-matcher-backend
├── app
│   ├── main.py
│   ├── routes
│   │   ├── analyze.py
│   │   └── rewrite.py
│   ├── services
│   │   ├── analyze_service.py
│   │   ├── rewrite_service.py
│   │   └── ollama_client.py
│   └── config
│       └── settings.py
├── requirements.txt
└── README.md
Core Components
Analyze Service

Performs resume-job matching using two techniques.

Keyword Matching

Extracts keywords from the job description

Compares against resume text

Calculates ATS-style keyword score

Semantic Similarity

Uses embeddings to understand meaning

Detects concept similarity even when wording differs

Improves match accuracy beyond simple keyword checks

The final score is calculated using a weighted combination.

Final Score = 0.4 × Keyword Score + 0.6 × Semantic Score
Rewrite Service

Generates resume improvement suggestions using a local LLM.

Input:

extracted resume text

job description

missing keywords

Output:

tailored professional summary

optimized skills section

rewritten resume bullet points

gap notes

Ollama Client

Handles communication with the local LLM engine.

Supported models:

qwen2.5:3b

phi3:mini

This allows the project to run fully locally without external AI APIs.

API Endpoints
Analyze Resume

POST /api/analyze

Accepts:

resume PDF

job description text

Returns:

{
  "keyword_score": 78,
  "semantic_score": 84,
  "final_score": 82,
  "matched_keywords": [],
  "missing_keywords": [],
  "extracted_resume_text": "..."
}
Rewrite Resume

POST /api/rewrite

Accepts:

{
  "resume_text": "...",
  "job_description": "...",
  "missing_keywords": []
}

Returns:

{
  "rewrite": {
    "tailored_summary": "...",
    "skills_section": [],
    "rewritten_bullets": [],
    "gap_notes": []
  }
}
Installation
1. Clone repository
git clone <your-backend-repo-url>
cd resume-matcher-backend
2. Create virtual environment
python -m venv .venv
source .venv/bin/activate
3. Install dependencies
pip install -r requirements.txt
4. Install Ollama

Download from:

https://ollama.com

Pull a model:

ollama pull qwen2.5:3b

or

ollama pull phi3:mini
5. Run backend server
uvicorn app.main:app --reload

Server will start at:

http://127.0.0.1:8000
Development Notes

Resume text extraction happens only once during analysis.

Rewrite requests reuse cached resume text to reduce latency.

Local LLM inference avoids external API costs.

Typical latency:

Feature	Time
Analyze	1–2s
Rewrite	2–5s
Future Improvements

Vector database integration

Resume embedding storage

Multi-job comparison

Resume version tracking

Streaming LLM responses

Advanced ATS keyword weighting

Tech Stack

FastAPI

Python

pdfplumber

sentence-transformers

Ollama

local LLM inference
