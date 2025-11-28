# Docker Hub myhub 레포지토리 이미지 삭제 및 새 이미지 푸시 스크립트

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Docker Hub 이미지 삭제 및 푸시" -ForegroundColor Cyan
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

# Docker Hub 로그인 안내
Write-Host "=== 2. Docker Hub 로그인 ===" -ForegroundColor Yellow
Write-Host "⚠️  Docker Hub 로그인이 필요합니다." -ForegroundColor Yellow
Write-Host "다음 명령어를 별도 터미널에서 실행해주세요:" -ForegroundColor Cyan
Write-Host "  docker login -u stonesteel84" -ForegroundColor White
Write-Host ""
$loginConfirm = Read-Host "로그인을 완료하셨나요? (y/n)"
if ($loginConfirm -ne "y" -and $loginConfirm -ne "Y") {
    Write-Host "로그인을 먼저 완료해주세요." -ForegroundColor Red
    exit 1
}
Write-Host ""

# 기존 로컬 이미지 삭제
Write-Host "=== 3. 로컬 기존 이미지 삭제 ===" -ForegroundColor Yellow
$existingImages = docker images stonesteel84/myhub --format "{{.ID}}"
if ($existingImages) {
    Write-Host "로컬에 기존 이미지가 있습니다. 삭제합니다..." -ForegroundColor Cyan
    docker rmi -f stonesteel84/myhub:latest 2>$null
    docker rmi -f stonesteel84/myhub:* 2>$null
    Write-Host "✅ 로컬 이미지 삭제 완료" -ForegroundColor Green
} else {
    Write-Host "로컬에 기존 이미지가 없습니다." -ForegroundColor Cyan
}
Write-Host ""

# Docker Hub에서 이미지 삭제 안내
Write-Host "=== 4. Docker Hub 웹사이트에서 이미지 삭제 ===" -ForegroundColor Yellow
Write-Host "⚠️  Docker Hub 웹사이트에서 직접 삭제해야 합니다:" -ForegroundColor Yellow
Write-Host "1. https://hub.docker.com/r/stonesteel84/myhub 접속" -ForegroundColor Cyan
Write-Host "2. 로그인 후 'Tags' 탭 클릭" -ForegroundColor Cyan
Write-Host "3. 삭제할 태그 옆 '...' 메뉴 클릭 → 'Delete' 선택" -ForegroundColor Cyan
Write-Host ""
$deleteConfirm = Read-Host "Docker Hub에서 이미지를 삭제하셨나요? (y/n)"
if ($deleteConfirm -ne "y" -and $deleteConfirm -ne "Y") {
    Write-Host "⚠️  계속 진행하지만, 기존 이미지가 남아있을 수 있습니다." -ForegroundColor Yellow
}
Write-Host ""

# 새 이미지 빌드
Write-Host "=== 5. 새 Docker 이미지 빌드 ===" -ForegroundColor Yellow
Write-Host "이미지명: stonesteel84/myhub" -ForegroundColor Cyan
Write-Host "태그: latest" -ForegroundColor Cyan
Write-Host ""
Write-Host "빌드 중... (시간이 걸릴 수 있습니다)" -ForegroundColor Cyan
docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="$env:NEXT_PUBLIC_SUPABASE_URL" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$env:NEXT_PUBLIC_SUPABASE_ANON_KEY" `
  -t stonesteel84/myhub:latest `
  .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 이미지 빌드 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 이미지 빌드 완료" -ForegroundColor Green
Write-Host ""

# 빌드된 이미지 확인
Write-Host "=== 6. 빌드된 이미지 확인 ===" -ForegroundColor Yellow
docker images stonesteel84/myhub
Write-Host ""

# 이미지 푸시
Write-Host "=== 7. Docker Hub에 푸시 ===" -ForegroundColor Yellow
Write-Host "푸시 중... (시간이 걸릴 수 있습니다)" -ForegroundColor Cyan
Write-Host ""
docker push stonesteel84/myhub:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 이미지 푸시 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 푸시 완료!" -ForegroundColor Green
Write-Host ""

# 완료 메시지
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🎉 모든 작업이 완료되었습니다!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 이미지 정보:" -ForegroundColor Yellow
Write-Host "   - stonesteel84/myhub:latest"
Write-Host ""
Write-Host "🌐 Docker Hub에서 확인:" -ForegroundColor Yellow
Write-Host "   https://hub.docker.com/r/stonesteel84/myhub"
Write-Host ""

