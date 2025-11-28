# Docker Hub 푸시 스크립트 (PowerShell)
# 사용법: .\docker-push.ps1

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Docker Hub 푸시 스크립트" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 환경 변수 확인
Write-Host "=== 1. 환경 변수 확인 ===" -ForegroundColor Yellow
if (-not $env:GEMINI_API_KEY -or -not $env:NEXT_PUBLIC_SUPABASE_URL -or -not $env:NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    Write-Host "❌ 필수 환경 변수가 설정되지 않았습니다!" -ForegroundColor Red
    Write-Host ""
    Write-Host "다음 환경 변수를 설정해주세요:" -ForegroundColor Yellow
    Write-Host "  - GEMINI_API_KEY"
    Write-Host "  - NEXT_PUBLIC_SUPABASE_URL"
    Write-Host "  - NEXT_PUBLIC_SUPABASE_ANON_KEY"
    exit 1
}
Write-Host "✅ 환경 변수 확인 완료" -ForegroundColor Green
Write-Host ""

# Docker Hub 로그인
Write-Host "=== 2. Docker Hub 로그인 ===" -ForegroundColor Yellow
Write-Host "Docker Hub 사용자명: stonesteel84" -ForegroundColor Cyan
docker login -u stonesteel84
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Hub 로그인 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 로그인 성공" -ForegroundColor Green
Write-Host ""

# 이미지 빌드
Write-Host "=== 3. Docker 이미지 빌드 ===" -ForegroundColor Yellow
Write-Host "이미지명: stonesteel84/new-mcp-server" -ForegroundColor Cyan
Write-Host "태그: latest, v1.0.0" -ForegroundColor Cyan
Write-Host ""
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
Write-Host ""

# 빌드된 이미지 확인
Write-Host "=== 4. 빌드된 이미지 확인 ===" -ForegroundColor Yellow
docker images | Select-String "stonesteel84/new-mcp-server"
Write-Host ""

# 이미지 푸시
Write-Host "=== 5. Docker Hub에 푸시 ===" -ForegroundColor Yellow
Write-Host "푸시 중... (시간이 걸릴 수 있습니다)" -ForegroundColor Cyan
Write-Host ""

Write-Host "📤 latest 태그 푸시 중..." -ForegroundColor Cyan
docker push stonesteel84/new-mcp-server:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ latest 태그 푸시 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ latest 태그 푸시 완료" -ForegroundColor Green
Write-Host ""

Write-Host "📤 v1.0.0 태그 푸시 중..." -ForegroundColor Cyan
docker push stonesteel84/new-mcp-server:v1.0.0

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ v1.0.0 태그 푸시 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ v1.0.0 태그 푸시 완료" -ForegroundColor Green
Write-Host ""

# 완료 메시지
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🎉 모든 작업이 완료되었습니다!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 이미지 정보:" -ForegroundColor Yellow
Write-Host "   - stonesteel84/new-mcp-server:latest"
Write-Host "   - stonesteel84/new-mcp-server:v1.0.0"
Write-Host ""
Write-Host "🌐 Docker Hub에서 확인:" -ForegroundColor Yellow
Write-Host "   https://hub.docker.com/r/stonesteel84/new-mcp-server"
Write-Host ""
Write-Host "다른 서버에서 사용:" -ForegroundColor Yellow
Write-Host "   docker pull stonesteel84/new-mcp-server:latest"
Write-Host ""

