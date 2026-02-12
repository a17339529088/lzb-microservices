# API测试脚本 (PowerShell版本)
# 使用方法: .\test-api.ps1 [服务器地址]
# 示例: .\test-api.ps1 http://124.222.11.237:7573

param(
    [string]$BaseUrl = "http://localhost:7573"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "LZB 微服务 API 测试" -ForegroundColor Cyan
Write-Host "服务器地址: $BaseUrl" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 测试1: 数据库登录
Write-Host "【测试1】数据库登录 (grant_type=password)" -ForegroundColor Yellow
Write-Host "请求: POST $BaseUrl/uaa/token?grant_type=password&username=admin&password=admin123"
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/uaa/token?grant_type=password&username=admin&password=admin123" -Method Post
    Write-Host "响应: " -NoNewline
    $response | ConvertTo-Json -Depth 10
    
    if ($response.code -eq 200) {
        $token = $response.data.accessToken
        Write-Host "✅ 登录成功，Token: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor Green
    } else {
        Write-Host "❌ 登录失败: $($response.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 测试2: LDAP登录
Write-Host "【测试2】LDAP登录 (grant_type=ldap)" -ForegroundColor Yellow
Write-Host "请求: POST $BaseUrl/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1"
try {
    $ldapResponse = Invoke-RestMethod -Uri "$BaseUrl/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1" -Method Post
    Write-Host "响应: " -NoNewline
    $ldapResponse | ConvertTo-Json -Depth 10
    
    if ($ldapResponse.code -eq 200) {
        Write-Host "✅ LDAP登录成功" -ForegroundColor Green
    } else {
        Write-Host "⚠️  LDAP登录失败（可能LDAP服务未启动）: $($ldapResponse.message)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  LDAP登录失败: $_" -ForegroundColor Yellow
}
Write-Host ""

# 测试3: 获取产品列表
Write-Host "【测试3】获取产品列表 (需要USER角色)" -ForegroundColor Yellow
Write-Host "请求: GET $BaseUrl/api/products"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $products = Invoke-RestMethod -Uri "$BaseUrl/api/products" -Method Get -Headers $headers
    Write-Host "响应: " -NoNewline
    $products | ConvertTo-Json -Depth 10
    Write-Host "✅ 获取产品列表成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
}
Write-Host ""

# 测试4: 创建产品
Write-Host "【测试4】创建产品 (需要EDITOR角色)" -ForegroundColor Yellow
Write-Host "请求: POST $BaseUrl/api/products"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    $body = @{
        name = "测试产品"
        description = "这是一个测试产品"
        status = "ON_SHELF"
    } | ConvertTo-Json
    
    $createResponse = Invoke-RestMethod -Uri "$BaseUrl/api/products" -Method Post -Headers $headers -Body $body
    Write-Host "响应: " -NoNewline
    $createResponse | ConvertTo-Json -Depth 10
    
    if ($createResponse.code -eq 200) {
        $productId = $createResponse.data.id
        Write-Host "✅ 产品创建成功，ID: $productId" -ForegroundColor Green
    } else {
        Write-Host "⚠️  产品创建失败，使用默认ID=1" -ForegroundColor Yellow
        $productId = 1
    }
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
    $productId = 1
}
Write-Host ""

# 测试5: 更新产品
Write-Host "【测试5】更新产品 (需要EDITOR角色)" -ForegroundColor Yellow
Write-Host "请求: PUT $BaseUrl/api/products/$productId"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    $body = @{
        name = "测试产品（已更新）"
        description = "这是一个更新后的测试产品"
        status = "ON_SHELF"
    } | ConvertTo-Json
    
    $updateResponse = Invoke-RestMethod -Uri "$BaseUrl/api/products/$productId" -Method Put -Headers $headers -Body $body
    Write-Host "响应: " -NoNewline
    $updateResponse | ConvertTo-Json -Depth 10
    Write-Host "✅ 产品更新成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
}
Write-Host ""

# 测试6: 再次获取产品列表
Write-Host "【测试6】再次获取产品列表" -ForegroundColor Yellow
Write-Host "请求: GET $BaseUrl/api/products"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $productsAfter = Invoke-RestMethod -Uri "$BaseUrl/api/products" -Method Get -Headers $headers
    Write-Host "响应: " -NoNewline
    $productsAfter | ConvertTo-Json -Depth 10
    Write-Host "✅ 获取产品列表成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
}
Write-Host ""

# 测试7: 删除产品
Write-Host "【测试7】删除产品 (需要EDITOR角色)" -ForegroundColor Yellow
Write-Host "请求: DELETE $BaseUrl/api/products/$productId"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $deleteResponse = Invoke-RestMethod -Uri "$BaseUrl/api/products/$productId" -Method Delete -Headers $headers
    Write-Host "响应: " -NoNewline
    $deleteResponse | ConvertTo-Json -Depth 10
    Write-Host "✅ 产品删除成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
}
Write-Host ""

# 测试8: 验证删除
Write-Host "【测试8】验证产品已删除" -ForegroundColor Yellow
Write-Host "请求: GET $BaseUrl/api/products"
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $productsFinal = Invoke-RestMethod -Uri "$BaseUrl/api/products" -Method Get -Headers $headers
    Write-Host "响应: " -NoNewline
    $productsFinal | ConvertTo-Json -Depth 10
    Write-Host "✅ 验证成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 请求失败: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "测试完成！" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
