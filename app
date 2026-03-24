import streamlit as st
import google.generativeai as genai
from firecrawl import FirecrawlApp

# --- PAGE CONFIG ---
st.set_page_config(page_title="FB Footy Summarizer", page_icon="⚽")

# --- API SETUP ---
# Securely getting keys from Streamlit Secrets
try:
    genai.configure(api_key=st.secrets["GEMINI_API_KEY"])
    firecrawl = FirecrawlApp(api_key=st.secrets["FIRECRAWL_API_KEY"])
except Exception as e:
    st.error("Missing API Keys! Please add them to your Streamlit Secrets.")

st.title("⚽ Football FB Summarizer")
st.caption("Paste a link, get a viral 200-char Facebook post.")

# --- INPUT ---
url = st.text_input("Article URL", placeholder="https://www.skysports.com/football/news/...")

if st.button("Generate FB Post"):
    if url:
        with st.spinner("Scraping and summarizing..."):
            try:
                # 1. Scrape the content
                scraped_data = firecrawl.scrape_url(url, params={'formats': ['markdown']})
                article_text = scraped_data.get('markdown', '')

                # 2. AI Prompt for strict 200-char Facebook style
                model = genai.GenerativeModel('gemini-1.5-flash')
                prompt = f"""
                Act as a viral football social media manager. 
                Summarize this article for a Facebook post.
                REQUIREMENTS:
                - Max 200 characters total.
                - Use 2 emojis.
                - Include 1 trending hashtag.
                - Make it punchy and engaging.
                ARTICLE: {article_text[:4000]} 
                """
                
                response = model.generate_content(prompt)
                summary = response.text.strip()

                # 3. Display Results
                st.subheader("Your Facebook Post")
                st.info(summary)
                
                # Metrics for the user
                char_count = len(summary)
                st.write(f"**Character Count:** {char_count}/200")
                
                if char_count > 200:
                    st.warning("⚠️ Slightly over 200 chars. You might want to trim it!")
                
                st.button("📋 Copy to Clipboard (Manual)", on_click=lambda: st.write("Copied! (Note: Standard browsers require a click to copy)"))

            except Exception as e:
                st.error(f"Error: {e}")
    else:
        st.warning("Please enter a valid URL.")

st.divider()
st.markdown("Created for the 2026 Football Season 🏆")
