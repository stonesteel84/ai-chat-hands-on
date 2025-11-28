# 빠른 푸시 스크립트 (환경 변수 자동 로드)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Docker Hub myhub 이미지 푸시" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 환경 변수 로드 (.cursor/mcp.json에서)
Write-Host "=== 환경 변수 로드 ===" -ForegroundColor Yellow
try {
    $mcpConfig = Get-Content .cursor/mcp.json | ConvertFrom-Json
    $envVars = $mcpConfig.mcpServers.context7.env
    
    if ($envVars.GEMINI_API_KEY) {
        $env:GEMINI_API_KEY = $envVars.GEMINI_API_KEY
        Write-Host "✅ GEMINI_API_KEY 로드됨" -ForegroundColor Green
    }
    if ($envVars.NEXT_PUBLIC_SUPABASE_URL) {
        $env:NEXT_PUBLIC_SUPABASE_URL = $envVars.NEXT_PUBLIC_SUPABASE_URL
        Write-Host "✅ NEXT_PUBLIC_SUPABASE_URL 로드됨" -ForegroundColor Green
    }
    if ($envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
        $env:NEXT_PUBLIC_SUPABASE_ANON_KEY = $envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY
        Write-Host "✅ NEXT_PUBLIC_SUPABASE_ANON_KEY 로드됨" -ForegroundColor Green
    }
    if ($envVars.LLM_MODEL) {
        $env:LLM_MODEL = $envVars.LLM_MODEL
    } else {
        $env:LLM_MODEL = "gemini-2.0-flash"
    }
} catch {
    Write-Host "⚠️  .cursor/mcp.json에서 환경 변수를 로드할 수 없습니다." -ForegroundColor Yellow
    Write-Host "수동으로 환경 변수를 설정해주세요." -ForegroundColor Yellow
}

# 환경 변수 확인
if (-not $env:GEMINI_API_KEY -or -not $env:NEXT_PUBLIC_SUPABASE_URL -or -not $env:NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    Write-Host "❌ 필수 환경 변수가 없습니다!" -ForegroundColor Red
    Write-Host "다음 명령어로 설정하세요:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your_key"' -ForegroundColor White
    Write-Host '  $env:NEXT_PUBLIC_SUPABASE_URL = "your_url"' -ForegroundColor White
    Write-Host '  $env:NEXT_PUBLIC_SUPABASE_ANON_KEY = "your_key"' -ForegroundColor White
    exit 1
}
Write-Host ""

# Docker Hub 로그인 확인
Write-Host "=== Docker Hub 로그인 확인 ===" -ForegroundColor Yellow
Write-Host "Docker Hub에 로그인해주세요:" -ForegroundColor Cyan
Write-Host "  docker login -u stonesteel84" -ForegroundColor White
Write-Host ""
$loginDone = Read-Host "로그인을 완료하셨나요? (y/n)"
if ($loginDone -ne "y" -and $loginDone -ne "Y") {
    Write-Host "로그인을 먼저 완료해주세요." -ForegroundColor Red
    exit 1
}
Write-Host ""

# 기존 로컬 이미지 삭제
Write-Host "=== 기존 로컬 이미지 삭제 ===" -ForegroundColor Yellow
docker rmi -f stonesteel84/myhub:latest 2>$null
Write-Host "✅ 완료" -ForegroundColor Green
Write-Host ""

# 이미지 빌드
Write-Host "=== Docker 이미지 빌드 ===" -ForegroundColor Yellow
Write-Host "이미지: stonesteel84/myhub:latest" -ForegroundColor Cyan
Write-Host "Building... (5-10 minutes)" -ForegroundColor Cyan
Write-Host ""
docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="$env:NEXT_PUBLIC_SUPABASE_URL" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$env:NEXT_PUBLIC_SUPABASE_ANON_KEY" `
  -t stonesteel84/myhub:latest `
  .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 빌드 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 빌드 완료" -ForegroundColor Green
Write-Host ""

# 이미지 푸시
Write-Host "=== Docker Hub에 푸시 ===" -ForegroundColor Yellow
Write-Host "Pushing... (3-10 minutes)" -ForegroundColor Cyan
Write-Host ""
docker push stonesteel84/myhub:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 푸시 실패" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 푸시 완료!" -ForegroundColor Green
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🎉 완료!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 이미지: stonesteel84/myhub:latest" -ForegroundColor Yellow
Write-Host "🌐 확인: https://hub.docker.com/r/stonesteel84/myhub" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Docker Hub 웹사이트에서 기존 태그를 삭제하려면:" -ForegroundColor Yellow
Write-Host "   https://hub.docker.com/r/stonesteel84/myhub → Tags 탭" -ForegroundColor Cyan
Write-Host ""

