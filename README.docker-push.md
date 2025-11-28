# Docker Hub 푸시 가이드 - 빠른 참조

## 📋 생성된 파일

1. **docker-push-guide.md** - 마크다운 가이드
2. **docker-push-guide.html** - HTML 가이드 (PDF 변환용)
3. **docker-push.sh** - Linux/Mac 자동화 스크립트
4. **docker-push.ps1** - Windows PowerShell 자동화 스크립트
5. **convert-to-pdf.md** - PDF 변환 방법 안내

## 🚀 빠른 시작

### Windows에서 실행

```powershell
# 1. 환경 변수 설정
$env:GEMINI_API_KEY = "your_key"
$env:NEXT_PUBLIC_SUPABASE_URL = "your_url"
$env:NEXT_PUBLIC_SUPABASE_ANON_KEY = "your_key"

# 2. 스크립트 실행
.\docker-push.ps1
```

### Linux/Mac에서 실행

```bash
# 1. 환경 변수 설정
export GEMINI_API_KEY="your_key"
export NEXT_PUBLIC_SUPABASE_URL="your_url"
export NEXT_PUBLIC_SUPABASE_ANON_KEY="your_key"

# 2. 스크립트 실행 권한 부여
chmod +x docker-push.sh

# 3. 실행
./docker-push.sh
```

## 📄 PDF 변환 방법

### 가장 간단한 방법 (권장)

1. `docker-push-guide.html` 파일을 더블클릭하여 브라우저에서 엽니다
2. `Ctrl + P` (또는 `Cmd + P`)를 누릅니다
3. "대상"에서 **"PDF로 저장"**을 선택합니다
4. 저장 위치를 선택하고 저장합니다

### 또는 명령어로 열기

```powershell
# Windows
Start-Process "docker-push-guide.html"

# Linux/Mac
open docker-push-guide.html  # Mac
xdg-open docker-push-guide.html  # Linux
```

## 📝 주요 명령어 요약

```bash
# 1. Docker Hub 로그인
docker login -u stonesteel84

# 2. 이미지 빌드
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
  -t stonesteel84/new-mcp-server:latest \
  -t stonesteel84/new-mcp-server:v1.0.0 \
  .

# 3. 이미지 푸시
docker push stonesteel84/new-mcp-server:latest
docker push stonesteel84/new-mcp-server:v1.0.0
```

## ✅ 확인

푸시 완료 후 다음 링크에서 확인:
https://hub.docker.com/r/stonesteel84/new-mcp-server

