ResumeSenseAI – iOS App

ResumeSenseAI is an iOS application that helps users understand how well their resume matches a job description and how they can improve it.

The app allows users to upload a resume PDF, paste a job description, and instantly see how strong their resume is for that role. It also generates AI-powered suggestions to improve the resume using a local LLM running through the backend.

This project was built as part of an AI engineering portfolio to explore how mobile apps can integrate with AI-powered backend services.

What the App Does

The app has two main features.

Resume Analysis

Users can upload their resume and paste a job description. The backend analyzes the resume and returns:

Keyword matching score (ATS-style)

Semantic similarity score

Final overall score

Matched keywords

Missing keywords

This helps users quickly see where their resume aligns with the job and where it needs improvement.

Resume Rewrite Suggestions

After running the analysis, users can generate AI-powered suggestions for improving their resume.

The AI suggests:

a tailored professional summary

recommended skills to highlight

improved resume bullet points

notes about potential gaps

These suggestions help the user adjust their resume to better match the job description.

Technologies Used

The iOS app is built with:

Swift

SwiftUI

MVVM architecture

URLSession for networking

FastAPI backend

Local LLM inference via Ollama

The UI is fully built in SwiftUI and communicates with the backend through REST APIs.

App Structure

The project is organized into a few simple layers.

ResumeSenseAI
│
├── App
│   └── ResumeSenseAIApp.swift
│
├── Models
│   ├── AnalyzeResponse.swift
│   └── RewriteResponse.swift
│
├── Network
│   └── APIClient.swift
│
├── ViewModels
│   └── ResumeMatcherVM.swift
│
├── Views
│   └── ContentView.swift
│
└── UI Components
    ├── Components.swift
    └── PDFPicker.swift
Models

Handle decoding responses from the backend APIs.

APIClient

Responsible for sending requests to the backend (/analyze and /rewrite).

ViewModel

Manages the application state and coordinates communication between the UI and the API.

Views

SwiftUI screens that render the UI and display analysis results.

Requirements

Xcode 15+

iOS 16 or later

ResumeSenseAI backend running locally or remotely

Running the App

Start the backend server first.

Example:

uvicorn app.main:app --reload

Open the iOS project in Xcode.

Make sure the backend URL is correct in APIClient.swift.

Example:

let baseURL = "http://127.0.0.1:8000"

If testing on a real iPhone, replace this with your computer's local IP.

Run the app on the simulator or device.

Typical Workflow

Upload a resume PDF

Paste a job description

Tap Analyze Resume

Review scores and keyword results

Tap Generate Rewrite

Review AI-generated improvements

Why This Project Exists

The goal of ResumeSenseAI was to explore how mobile applications can integrate with AI systems.

Instead of calling cloud APIs, the app works with a backend that runs local LLM inference using Ollama, which makes it possible to experiment with AI features without relying on external services.

It also demonstrates:

building AI-assisted tools

integrating mobile apps with AI backends

designing structured LLM outputs

building end-to-end AI products
