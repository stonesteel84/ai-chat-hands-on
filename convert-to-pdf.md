# PDF 변환 방법

## 방법 1: 브라우저에서 직접 변환 (가장 간단)

1. `docker-push-guide.html` 파일을 브라우저에서 엽니다
2. `Ctrl + P` (또는 `Cmd + P` on Mac)를 눌러 인쇄 대화상자를 엽니다
3. "대상" 또는 "Destination"에서 **"PDF로 저장"** 또는 **"Save as PDF"**를 선택합니다
4. "저장" 또는 "Save"를 클릭합니다

## 방법 2: Pandoc 사용 (설치 필요)

```bash
# Pandoc 설치 확인
pandoc --version

# PDF 변환 (LaTeX 필요)
pandoc docker-push-guide.md -o docker-push-guide.pdf --pdf-engine=xelatex

# 또는 wkhtmltopdf 사용
pandoc docker-push-guide.html -o docker-push-guide.pdf
```

## 방법 3: 온라인 변환 도구 사용

1. https://www.markdowntopdf.com/ 접속
2. `docker-push-guide.md` 파일 업로드
3. PDF 다운로드

## 방법 4: VS Code 확장 사용

1. VS Code에서 "Markdown PDF" 확장 설치
2. `docker-push-guide.md` 파일 열기
3. `Ctrl + Shift + P` → "Markdown PDF: Export (pdf)" 선택

