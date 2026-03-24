import streamlit as st
import google.generativeai as genai
from firecrawl import FirecrawlApp

# 1. Setup API Keys (Add these in Streamlit Cloud Secrets!)
genai.configure(api_key=st.secrets["GEMINI_API_KEY"])
firecrawl = FirecrawlApp(api_key=st.secrets["FIRECRAWL_API_KEY"])

st.title("⚽ Football News Summarizer")
url = st.text_input("Paste a football article link:")

if url:
    with st.spinner("Scraping and Summarizing..."):
        # STEP A: Scrape the full text
        scraped_data = firecrawl.scrape_url(url, params={'formats': ['markdown']})
        full_text = scraped_data['markdown']
        
        # STEP B: Summarize with Gemini
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(f"Summarize this football news article in 3 bullet points: {full_text}")
        
        # STEP C: Display
        st.subheader("Summary")
        st.write(response.text)
