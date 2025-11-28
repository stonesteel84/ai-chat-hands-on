# Docker 배포 가이드

## 사전 요구사항

- Docker 및 Docker Compose 설치
- 환경 변수 설정

## 환경 변수 설정

`.docker.env` 파일을 생성하고 다음 변수를 설정하세요:

```bash
GEMINI_API_KEY=your_gemini_api_key
LLM_MODEL=gemini-2.0-flash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 빌드 및 실행

### Docker Compose 사용 (권장)

```bash
# 환경 변수 파일 사용
docker-compose --env-file .docker.env up -d

# 또는 환경 변수를 직접 설정
GEMINI_API_KEY=xxx LLM_MODEL=gemini-2.0-flash docker-compose up -d
```

### Docker 직접 사용

```bash
# 이미지 빌드
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL} \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY} \
  -t ai-chat-hands-on:latest .

# 컨테이너 실행
docker run -d \
  -p 4000:4000 \
  -e GEMINI_API_KEY=${GEMINI_API_KEY} \
  -e LLM_MODEL=${LLM_MODEL} \
  -e NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL} \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY} \
  --name ai-chat-app \
  --restart unless-stopped \
  ai-chat-hands-on:latest
```

## 확인

서버가 실행되면 http://localhost:4000 에서 접속할 수 있습니다.

## 로그 확인

```bash
# Docker Compose
docker-compose logs -f

# Docker 직접
docker logs -f ai-chat-app
```

## 중지

```bash
# Docker Compose
docker-compose down

# Docker 직접
docker stop ai-chat-app
docker rm ai-chat-app
```

## 문제 해결

### 포트 충돌
포트 4000이 이미 사용 중인 경우, `docker-compose.yml`의 포트 매핑을 변경하세요:
```yaml
ports:
  - "3000:4000"  # 호스트:컨테이너
```

### 빌드 실패
환경 변수가 제대로 설정되었는지 확인하세요:
```bash
echo $GEMINI_API_KEY
echo $NEXT_PUBLIC_SUPABASE_URL
```

