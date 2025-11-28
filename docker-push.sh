#!/bin/bash

# Docker Hub 푸시 스크립트
# 사용법: ./docker-push.sh

set -e  # 오류 발생 시 스크립트 중단

echo "=========================================="
echo "Docker Hub 푸시 스크립트"
echo "=========================================="
echo ""

# 환경 변수 확인
echo "=== 1. 환경 변수 확인 ==="
if [ -z "$GEMINI_API_KEY" ] || [ -z "$NEXT_PUBLIC_SUPABASE_URL" ] || [ -z "$NEXT_PUBLIC_SUPABASE_ANON_KEY" ]; then
    echo "❌ 필수 환경 변수가 설정되지 않았습니다!"
    echo ""
    echo "다음 환경 변수를 설정해주세요:"
    echo "  - GEMINI_API_KEY"
    echo "  - NEXT_PUBLIC_SUPABASE_URL"
    echo "  - NEXT_PUBLIC_SUPABASE_ANON_KEY"
    exit 1
fi
echo "✅ 환경 변수 확인 완료"
echo ""

# Docker Hub 로그인
echo "=== 2. Docker Hub 로그인 ==="
echo "Docker Hub 사용자명: stonesteel84"
docker login -u stonesteel84
if [ $? -ne 0 ]; then
    echo "❌ Docker Hub 로그인 실패"
    exit 1
fi
echo "✅ 로그인 성공"
echo ""

# 이미지 빌드
echo "=== 3. Docker 이미지 빌드 ==="
echo "이미지명: stonesteel84/new-mcp-server"
echo "태그: latest, v1.0.0"
echo ""
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
echo ""

# 빌드된 이미지 확인
echo "=== 4. 빌드된 이미지 확인 ==="
docker images | grep stonesteel84/new-mcp-server
echo ""

# 이미지 푸시
echo "=== 5. Docker Hub에 푸시 ==="
echo "푸시 중... (시간이 걸릴 수 있습니다)"
echo ""

echo "📤 latest 태그 푸시 중..."
docker push stonesteel84/new-mcp-server:latest

if [ $? -ne 0 ]; then
    echo "❌ latest 태그 푸시 실패"
    exit 1
fi
echo "✅ latest 태그 푸시 완료"
echo ""

echo "📤 v1.0.0 태그 푸시 중..."
docker push stonesteel84/new-mcp-server:v1.0.0

if [ $? -ne 0 ]; then
    echo "❌ v1.0.0 태그 푸시 실패"
    exit 1
fi
echo "✅ v1.0.0 태그 푸시 완료"
echo ""

# 완료 메시지
echo "=========================================="
echo "🎉 모든 작업이 완료되었습니다!"
echo "=========================================="
echo ""
echo "📦 이미지 정보:"
echo "   - stonesteel84/new-mcp-server:latest"
echo "   - stonesteel84/new-mcp-server:v1.0.0"
echo ""
echo "🌐 Docker Hub에서 확인:"
echo "   https://hub.docker.com/r/stonesteel84/new-mcp-server"
echo ""
echo "다른 서버에서 사용:"
echo "   docker pull stonesteel84/new-mcp-server:latest"
echo ""

