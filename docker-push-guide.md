# Docker Hub 푸시 가이드

## 목표
Docker 이미지를 빌드하고 `stonesteel84/new-mcp-server` 레포지토리에 푸시하기

---

## 사전 준비사항

1. Docker 설치 확인
2. Docker Hub 계정 로그인
3. 환경 변수 설정

---

## 단계별 실행 과정

### 1단계: 환경 변수 확인

```bash
# 현재 환경 변수 확인
echo "GEMINI_API_KEY: ${GEMINI_API_KEY:0:10}..."
echo "NEXT_PUBLIC_SUPABASE_URL: $NEXT_PUBLIC_SUPABASE_URL"
echo "NEXT_PUBLIC_SUPABASE_ANON_KEY: ${NEXT_PUBLIC_SUPABASE_ANON_KEY:0:20}..."
```

**필수 환경 변수:**
- `GEMINI_API_KEY`: Gemini API 키
- `LLM_MODEL`: 사용할 모델 (기본값: gemini-2.0-flash)
- `NEXT_PUBLIC_SUPABASE_URL`: Supabase 프로젝트 URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase 익명 키

---

### 2단계: Docker Hub 로그인

```bash
# Docker Hub에 로그인
docker login

# 또는 사용자명 직접 지정
docker login -u stonesteel84
```

**실행 결과 예시:**
```
Username: stonesteel84
Password: ********
Login Succeeded
```

---

### 3단계: Docker 이미지 빌드

```bash
# 프로젝트 루트 디렉토리에서 실행
cd /path/to/ai-chat-hands-on-feature-mcp-client-3

# 이미지 빌드 (빌드 인자 포함)
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
  -t stonesteel84/new-mcp-server:latest \
  -t stonesteel84/new-mcp-server:v1.0.0 \
  .
```

**빌드 과정 설명:**
- `--build-arg`: 빌드 시 필요한 환경 변수 전달
- `-t`: 이미지 태그 지정 (latest와 버전 태그 모두 지정)
- `.`: 현재 디렉토리를 빌드 컨텍스트로 사용

**예상 빌드 시간:** 5-10분 (첫 빌드 시)

**빌드 성공 확인:**
```bash
docker images | grep stonesteel84/new-mcp-server
```

**출력 예시:**
```
REPOSITORY                      TAG       IMAGE ID       CREATED         SIZE
stonesteel84/new-mcp-server     latest    abc123def456   2 minutes ago   450MB
stonesteel84/new-mcp-server     v1.0.0    abc123def456   2 minutes ago   450MB
```

---

### 4단계: 이미지 태그 확인

```bash
# 빌드된 이미지 목록 확인
docker images stonesteel84/new-mcp-server
```

---

### 5단계: Docker Hub에 푸시

```bash
# latest 태그 푸시
docker push stonesteel84/new-mcp-server:latest

# 버전 태그 푸시
docker push stonesteel84/new-mcp-server:v1.0.0
```

**푸시 과정 설명:**
1. 이미지 레이어 압축 및 업로드
2. Docker Hub에 메타데이터 전송
3. 레포지토리에 이미지 등록

**예상 푸시 시간:** 3-10분 (이미지 크기에 따라)

**푸시 진행 상황 예시:**
```
The push refers to repository [docker.io/stonesteel84/new-mcp-server]
abc123def456: Pushing [==================================================>]  450MB
def456ghi789: Pushing [==================================================>]  120MB
...
latest: digest: sha256:abc123... size: 1234
```

---

### 6단계: 푸시 확인

#### 방법 1: Docker Hub 웹사이트 확인
1. https://hub.docker.com 접속
2. 로그인 후 `stonesteel84/new-mcp-server` 레포지토리 확인
3. 이미지가 업로드되었는지 확인

#### 방법 2: 명령어로 확인
```bash
# 이미지 정보 확인
docker inspect stonesteel84/new-mcp-server:latest

# 원격 레포지토리에서 pull 테스트
docker pull stonesteel84/new-mcp-server:latest
```

---

## 전체 명령어 한번에 실행

```bash
#!/bin/bash

# 환경 변수 확인
echo "=== 환경 변수 확인 ==="
if [ -z "$GEMINI_API_KEY" ] || [ -z "$NEXT_PUBLIC_SUPABASE_URL" ] || [ -z "$NEXT_PUBLIC_SUPABASE_ANON_KEY" ]; then
    echo "❌ 필수 환경 변수가 설정되지 않았습니다!"
    exit 1
fi
echo "✅ 환경 변수 확인 완료"

# Docker Hub 로그인
echo "=== Docker Hub 로그인 ==="
docker login -u stonesteel84
if [ $? -ne 0 ]; then
    echo "❌ Docker Hub 로그인 실패"
    exit 1
fi
echo "✅ 로그인 성공"

# 이미지 빌드
echo "=== Docker 이미지 빌드 ==="
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
  -t stonesteel84/new-mcp-server:latest \
  -t stonesteel84/new-mcp-server:v1.0.0 \
  .

if [ $? -ne 0 ]; then
    echo "❌ 이미지 빌드 실패"
    exit 1
fi
echo "✅ 이미지 빌드 완료"

# 이미지 푸시
echo "=== Docker Hub에 푸시 ==="
docker push stonesteel84/new-mcp-server:latest
docker push stonesteel84/new-mcp-server:v1.0.0

if [ $? -ne 0 ]; then
    echo "❌ 이미지 푸시 실패"
    exit 1
fi
echo "✅ 푸시 완료!"

echo ""
echo "🎉 모든 작업이 완료되었습니다!"
echo "📦 이미지: stonesteel84/new-mcp-server:latest"
echo "🌐 확인: https://hub.docker.com/r/stonesteel84/new-mcp-server"
```

---

## Windows PowerShell 스크립트

```powershell
# 환경 변수 확인
Write-Host "=== 환경 변수 확인 ===" -ForegroundColor Cyan
if (-not $env:GEMINI_API_KEY -or -not $env:NEXT_PUBLIC_SUPABASE_URL -or -not $env:NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    Write-Host "❌ 필수 환경 변수가 설정되지 않았습니다!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 환경 변수 확인 완료" -ForegroundColor Green

# Docker Hub 로그인
Write-Host "=== Docker Hub 로그인 ===" -ForegroundColor Cyan
docker login -u stonesteel84
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Hub 로그인 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 로그인 성공" -ForegroundColor Green

# 이미지 빌드
Write-Host "=== Docker 이미지 빌드 ===" -ForegroundColor Cyan
docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="$env:NEXT_PUBLIC_SUPABASE_URL" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$env:NEXT_PUBLIC_SUPABASE_ANON_KEY" `
  -t stonesteel84/new-mcp-server:latest `
  -t stonesteel84/new-mcp-server:v1.0.0 `
  .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 이미지 빌드 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 이미지 빌드 완료" -ForegroundColor Green

# 이미지 푸시
Write-Host "=== Docker Hub에 푸시 ===" -ForegroundColor Cyan
docker push stonesteel84/new-mcp-server:latest
docker push stonesteel84/new-mcp-server:v1.0.0

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 이미지 푸시 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 푸시 완료!" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 모든 작업이 완료되었습니다!" -ForegroundColor Green
Write-Host "📦 이미지: stonesteel84/new-mcp-server:latest"
Write-Host "🌐 확인: https://hub.docker.com/r/stonesteel84/new-mcp-server"
```

---

## 문제 해결

### 1. 빌드 실패: 환경 변수 누락
```bash
# 해결: 환경 변수 설정 확인
echo $GEMINI_API_KEY
echo $NEXT_PUBLIC_SUPABASE_URL
```

### 2. 로그인 실패
```bash
# 해결: 토큰 사용 (권장)
docker login -u stonesteel84 --password-stdin < ~/docker-token.txt
```

### 3. 푸시 실패: 권한 없음
```bash
# 해결: Docker Hub에서 레포지토리 생성 확인
# https://hub.docker.com/repositories 에서 확인
```

### 4. 네트워크 오류
```bash
# 해결: 프록시 설정 또는 재시도
docker push stonesteel84/new-mcp-server:latest --retry 3
```

---

## 이미지 사용 방법

### 다른 서버에서 이미지 사용

```bash
# 이미지 pull
docker pull stonesteel84/new-mcp-server:latest

# 컨테이너 실행
docker run -d \
  -p 4000:4000 \
  -e GEMINI_API_KEY=your_key \
  -e LLM_MODEL=gemini-2.0-flash \
  -e NEXT_PUBLIC_SUPABASE_URL=your_url \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key \
  --name new-mcp-server \
  stonesteel84/new-mcp-server:latest
```

---

## 체크리스트

- [ ] Docker 설치 확인
- [ ] Docker Hub 계정 로그인
- [ ] 환경 변수 설정 확인
- [ ] 이미지 빌드 성공
- [ ] 이미지 푸시 성공
- [ ] Docker Hub에서 이미지 확인

---

## 참고 링크

- Docker Hub: https://hub.docker.com/r/stonesteel84/new-mcp-server
- Docker 문서: https://docs.docker.com/
- Next.js Docker 가이드: https://nextjs.org/docs/deployment#docker-image

---

**작성일:** 2025-11-28  
**버전:** 1.0.0

